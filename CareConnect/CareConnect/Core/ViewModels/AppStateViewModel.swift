//
//  AppStateViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AppStateViewModel: ObservableObject {
    // Auth / User
    @Published var isLoggedIn = false
    @Published var currentUser: User? = nil
    @Published var role: String? = nil

    // Daten
    @Published var employees: [Employee] = []
    @Published var patients:  [Patient]  = []
    @Published var orders:    [Order]    = []

    // Status (lokal + Server)
    @Published var staffStatus: StaffStatus = {
        let raw = UserDefaults.standard.string(forKey: "staffStatus") ?? StaffStatus.available.rawValue
        return StaffStatus(rawValue: raw) ?? .available
    }() {
        didSet { UserDefaults.standard.set(staffStatus.rawValue, forKey: "staffStatus") }
    }

    // UI
    @AppStorage("isDarkMode") var isDarkMode = false
    @Published var searchText = ""

    // Service & Listener
    private let service: FirebaseServiceType = FirebaseLiveService()
    private var listeners: [ListenerRegistration] = []
    private var listenersStarted = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        checkLoginState()
        print("✅ AppStateViewModel initialisiert")
        verifyFirestoreConnection()
        setupForegroundReload()
    }

    // MARK: - Firestore Connection Test
    private func verifyFirestoreConnection() {
        let db = Firestore.firestore()
        db.collection("test").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore-Verbindungstest fehlgeschlagen:", error.localizedDescription)
            } else {
                print("✅ Firestore-Verbindung erfolgreich geprüft (\(snapshot?.count ?? 0) Dokumente abrufbar).")
            }
        }
    }

    // MARK: - Foreground Reload
    private func setupForegroundReload() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("🔔 App kommt in den Vordergrund – reloading Firestore-Daten …")
                Task { await self.reloadData() }
            }
            .store(in: &cancellables)
    }

    // MARK: Auth
    func checkLoginState() {
        if let user = Auth.auth().currentUser {
            setLoggedIn(user: user)
        } else {
            isLoggedIn = false
            currentUser = nil
            role = nil
        }
    }

    func setLoggedIn(user: User) {
        isLoggedIn = true
        currentUser = user
        Task {
            await loadUserRole(uid: user.uid)
            if role == "Mitarbeiter" {
                EmployeeLocationManager.shared.startTracking(for: user.uid)
            }
            if role == "Patient" {
                await loadCurrentPatient()
            } else {
                currentPatient = nil
            }

            await loadInitial()
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            print("👋 Benutzer erfolgreich abgemeldet.")
        } catch {
            print("❌ Logout:", error.localizedDescription)
        }
        EmployeeLocationManager.shared.stopTracking()
        isLoggedIn = false
        currentUser = nil
        role = nil
        Task { await clearListeners() }
        employees.removeAll()
        patients.removeAll()
        orders.removeAll()
        currentPatient = nil
        Task { await self.reloadData() }
    }

    // MARK: Rolle laden (Patient/Mitarbeiter)
    private func loadUserRole(uid: String) async {
        guard !uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Ungültige UID für loadUserRole()")
            role = nil
            return
        }
        let db = Firestore.firestore()
        do {
            let emp = try await db.collection("employees").document(uid).getDocument()
            if emp.exists { role = "Mitarbeiter"; return }
            let pat = try await db.collection("patients").document(uid).getDocument()
            if pat.exists { role = "Patient"; return }
            role = nil
        } catch {
            print("⚠️ Rolle konnte nicht geladen werden:", error.localizedDescription)
            role = nil
        }
    }

    /// Daten laden + Sync
    // MARK: Daten laden + Live-Sync
    func loadInitial() async {
        async let e: [Employee] = (try? await service.fetchEmployees()) ?? []
        async let p: [Patient]  = (try? await service.fetchPatients())  ?? []
        async let o: [Order]    = (try? await service.fetchOrders())    ?? []

        let employeesResult = await e
        let patientsResult  = await p
        let ordersResult    = await o

        await MainActor.run {
            self.employees = employeesResult
            self.patients  = patientsResult
            self.orders    = ordersResult
        }

        startRealtimeListenersIfNeeded()
    }

    // Startet Realtime-Listener genau 1×
    func startRealtimeListenersIfNeeded() {
        guard !listenersStarted else { return }
        listenersStarted = true
        Task { await observeAll() }
    }

    func observeAll() async {
        if listenersStarted == false { listenersStarted = true }
        await clearListeners()

        // Employees
        let employeeListener = service.listen(to: "employees", as: Employee.self) { [weak self] res in
            switch res {
            case .success(let list):
                Task { @MainActor in
                    self?.employees = list
                    print("📥 Employees empfangen: \(list.count)")
                }
            case .failure(let error):
                print("⚠️ Listener-Fehler bei employees:", error.localizedDescription)
            }
        }
        listeners.append(employeeListener)

        // Patients
        let patientListener = service.listen(to: "patients", as: Patient.self) { [weak self] res in
            switch res {
            case .success(let list):
                Task { @MainActor in
                    self?.patients = list
                    print("📥 Patients empfangen: \(list.count)")
                }
            case .failure(let error):
                print("⚠️ Listener-Fehler bei patients:", error.localizedDescription)
            }
        }
        listeners.append(patientListener)

        // Orders
        let orderListener = service.listen(to: "orders", as: Order.self) { [weak self] res in
            switch res {
            case .success(let list):
                Task { @MainActor in
                    self?.orders = list
                    print("📥 Orders empfangen: \(list.count)")
                }
            case .failure(let error):
                print("⚠️ Listener-Fehler bei orders:", error.localizedDescription)
            }
        }
        listeners.append(orderListener)
    }

    // MARK: Aktueller Mitarbeiter
    var currentEmployee: Employee? {
        guard let mail = currentUser?.email else { return nil }
        return employees.first { $0.email.caseInsensitiveCompare(mail) == .orderedSame }
    }

    // MARK: Aktueller Patient
    @Published var currentPatient: Patient? = nil

    func loadCurrentPatient() async {
        guard let user = currentUser else { return }
        guard role == "Patient" else { return }
        let db = Firestore.firestore()

        do {
            let docByID = try await db.collection("patients").document(user.uid).getDocument()
            if docByID.exists {
                currentPatient = try docByID.data(as: Patient.self)
                print("✅ Patient (per DocID) geladen: \(currentPatient?.firstName ?? "") \(currentPatient?.lastName ?? "")")
                return
            }

            let qByUID = try await db.collection("patients")
                .whereField("uid", isEqualTo: user.uid)
                .limit(to: 1)
                .getDocuments()
            if let doc = qByUID.documents.first {
                currentPatient = try doc.data(as: Patient.self)
                print("✅ Patient (per UID-Feld) geladen: \(currentPatient?.firstName ?? "") \(currentPatient?.lastName ?? "")")
                return
            }

            if let email = user.email, !email.isEmpty {
                let qByEmail = try await db.collection("patients")
                    .whereField("email", isEqualTo: email)
                    .limit(to: 1)
                    .getDocuments()
                if let doc = qByEmail.documents.first {
                    currentPatient = try doc.data(as: Patient.self)
                    print("✅ Patient (per E-Mail) geladen: \(currentPatient?.firstName ?? "") \(currentPatient?.lastName ?? "")")
                    return
                }
            }

            print("⚠️ Kein Patientenprofil für Benutzer mit UID \(user.uid) gefunden — Profil wird automatisch erstellt.")
            await ensureCurrentPatientExistsFixed()

        } catch let error as NSError {
            if error.domain == "FIRFirestoreErrorDomain" {
                print("⚠️ Firestore-Zugriff verweigert (Permissions).")
            } else {
                print("❌ Fehler beim Laden des Patientenprofils:", error.localizedDescription)
            }
            currentPatient = nil
        }
    }

    // MARK: Patient-Profil anlegen, falls nicht vorhanden
    func ensureCurrentPatientExists() async {
        guard let user = currentUser else { return }
        let db = Firestore.firestore()

        do {
            let existing = try await db.collection("patients")
                .whereField("uid", isEqualTo: user.uid)
                .limit(to: 1)
                .getDocuments()

            if let _ = existing.documents.first {
                await loadCurrentPatient()
                return
            }

            let email = user.email ?? ""
            try await db.collection("patients").document(user.uid).setData([
                "uid": user.uid,
                "firstName": "",
                "lastName": "",
                "email": email,
                "address": "",
                "city": "",
                "createdAt": Timestamp(date: Date())
            ], merge: true)

            await loadCurrentPatient()
            print("✅ Neues Patientenprofil wurde erstellt und geladen.")
        } catch {
            print("❌ Fehler beim Anlegen des Patientenprofils:", error.localizedDescription)
        }
    }

    // MARK: Patient-Profil anlegen (verbesserte Version mit fester UID)
    func ensureCurrentPatientExistsFixed() async {
        guard let user = currentUser else { return }
        guard role == "Patient" else { return }
        guard !user.uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Ungültige UID – Patient kann nicht erstellt werden.")
            return
        }
        let db = Firestore.firestore()

        do {
            let existingDoc = try await db.collection("patients").document(user.uid).getDocument()
            if existingDoc.exists {
                print("ℹ️ Patientenprofil existiert bereits für UID \(user.uid)")
                await loadCurrentPatient()
                return
            }

            let email = user.email ?? ""
            try await db.collection("patients").document(user.uid).setData([
                "uid": user.uid,
                "firstName": "",
                "lastName": "",
                "email": email,
                "address": "",
                "city": "",
                "createdAt": Timestamp(date: Date())
            ], merge: true)

            print("✅ Neues Patientenprofil wurde erstellt (ID = Auth UID: \(user.uid))")
            await loadCurrentPatient()
        } catch {
            print("❌ Fehler beim Erstellen des Patientenprofils:", error.localizedDescription)
        }
    }

    // MARK: Status → Firestore
    func updateCurrentStatus(_ status: StaffStatus) async {
        guard let emp = currentEmployee, let id = emp.id else { return }
        do {
            try await service.updateEmployee(id: id, fields: ["status": status.rawValue])
            staffStatus = status
            Task { await self.reloadData() }
        } catch {
            print("❌ Status-Update:", error.localizedDescription)
        }
    }

    // MARK: Suche
    func filteredEmployees(_ q: String) -> [Employee] {
        let s = q.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return employees }
        return employees.filter { "\($0.firstName) \($0.lastName) \($0.role)".lowercased().contains(s) }
    }

    func filteredPatients(_ q: String) -> [Patient] {
        let s = q.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return patients }
        return patients.filter { "\($0.firstName) \($0.lastName) \($0.address)".lowercased().contains(s) }
    }

    func filteredOrders(_ q: String) -> [Order] {
        let s = q.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return orders }
        return orders.filter {
            let fullName = ($0.patientName ?? "").lowercased()
            return ($0.notes?.joined(separator: " ").lowercased().contains(s) ?? false) || fullName.contains(s)
        }
    }

    // MARK: Listener-Aufräumen
    private func clearListeners() async {
        for l in listeners { l.remove() }
        listeners.removeAll()
        listenersStarted = false
    }

    // MARK: - Reload Firestore Data
    func reloadData() async {
        print("🔄 Starte Daten-Neuladen (Employees, Patients, Orders)...")
        async let e: [Employee] = (try? await service.fetchEmployees()) ?? []
        async let p: [Patient]  = (try? await service.fetchPatients())  ?? []
        async let o: [Order]    = (try? await service.fetchOrders())    ?? []
        
        let employeesResult = await e
        let patientsResult  = await p
        let ordersResult    = await o
        
        await MainActor.run {
            self.employees = employeesResult
            self.patients  = patientsResult
            self.orders    = ordersResult
            print("✅ Firestore-Daten neu geladen (\(employeesResult.count) Mitarbeiter, \(patientsResult.count) Patienten, \(ordersResult.count) Aufträge).")
        }
    }

deinit {
    if !listeners.isEmpty {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
}

// MARK: Dringlicher Auftrag (Emergency Order)
func createEmergencyOrder(for userID: String) async {
    let trimmedID = userID.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedID.isEmpty else {
        print("⚠️ Ungültige Benutzer-ID für Notfallauftrag.")
        return
    }

    print("🆘 Erstelle dringlichen Auftrag für Benutzer-ID: \(trimmedID)")
    let db = Firestore.firestore()
    let orderID = UUID().uuidString
    let orderData: [String: Any] = [
        "id": orderID,
        "patientId": trimmedID,
        "patientName": "",
        "description": "Notfallauftrag",
        "createdBy": Auth.auth().currentUser?.uid ?? "unknown",
        "createdAt": FieldValue.serverTimestamp(),
        "dueDate": Timestamp(date: Date()),
        "state": "offen",
        "notes": ["Automatisch generierter Notfallauftrag"]
    ]

    do {
        try await db.collection("orders").document(orderID).setData(orderData)
        print("✅ Notfallauftrag erfolgreich erstellt.")
        Task { await self.reloadData() }
    } catch {
        print("❌ Fehler beim Erstellen des Notfallauftrags:", error.localizedDescription)
    }
}
}
