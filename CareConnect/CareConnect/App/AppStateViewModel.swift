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
    @Published var role: String? = nil            // "Mitarbeiter" | "Patient"

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

    init() { checkLoginState() }

    // MARK: - Auth
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
            await loadInitial()
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Logout:", error.localizedDescription)
        }
        isLoggedIn = false
        currentUser = nil
        role = nil
        Task { await clearListeners() }
    }

    // MARK: - Rolle laden (Patient/Mitarbeiter)
    private func loadUserRole(uid: String) async {
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

    // MARK: - Daten laden + Live-Sync
    func loadInitial() async {
        async let e: [Employee] = (try? await service.fetchEmployees()) ?? []
        async let p: [Patient]  = (try? await service.fetchPatients())  ?? []
        async let o: [Order]    = (try? await service.fetchOrders())    ?? []
        employees = await e
        patients  = await p
        orders    = await o
        await observeAll()
    }

    func observeAll() async {
        await clearListeners()

        listeners.append(service.listen(to: "employees", as: Employee.self) { [weak self] res in
            if case .success(let list) = res { Task { @MainActor in self?.employees = list } }
        })
        listeners.append(service.listen(to: "patients", as: Patient.self) { [weak self] res in
            if case .success(let list) = res { Task { @MainActor in self?.patients = list } }
        })
        listeners.append(service.listen(to: "orders", as: Order.self) { [weak self] res in
            if case .success(let list) = res { Task { @MainActor in self?.orders = list } }
        })
    }

    // MARK: - Aktueller Mitarbeiter
    var currentEmployee: Employee? {
        guard let mail = currentUser?.email else { return nil }
        return employees.first { $0.email.caseInsensitiveCompare(mail) == .orderedSame }
    }

    // MARK: - Status → Firestore
    func updateCurrentStatus(_ status: StaffStatus) async {
        guard let emp = currentEmployee, let id = emp.id else { return }
        do {
            try await service.updateEmployee(id: id, fields: ["status": status.rawValue])
            staffStatus = status
        } catch {
            print("❌ Status-Update:", error.localizedDescription)
        }
    }

    // MARK: - Suche
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
            ($0.notes ?? "").lowercased().contains(s) || $0.patientId.lowercased().contains(s)
        }
    }

    // MARK: - Listener-Aufräumen
    private func clearListeners() async {
        for l in listeners { l.remove() }
        listeners.removeAll()
    }

    deinit { Task { await clearListeners() } }
}

