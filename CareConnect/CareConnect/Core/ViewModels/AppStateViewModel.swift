//
//  AppStateViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import SwiftUI

/// Sitzung, aktuelle Organisation, Einstellungen und gemeinsame Live-Daten für die ganze App.
/// Ablauf: Login → Profil → Organisation wählen/gründen → Mitarbeiter- oder Patienten-App
@MainActor
@Observable
final class AppStateViewModel {

    enum SessionState {
        case loading
        case loggedOut
        /// Konto da, aber noch kein Profil unter users/{uid} (z. B. Registrierung läuft noch)
        case missingProfile
        /// Noch keiner Organisation beigetreten
        case needsOrganization
        case loggedIn
    }

    // MARK: - Sitzung

    private(set) var session: SessionState = .loading
    private(set) var userId: String?
    private(set) var profile: UserProfile?
    private(set) var memberships: [Membership] = []
    /// Aktuelle Organisation mit der Rolle, wie sie dort gerade steht
    private(set) var membership: Membership?
    var message: String?

    // MARK: - Live-Daten der Organisation

    private(set) var employees: [Employee] = []
    private(set) var patients: [Patient] = []
    private(set) var orders: [Order] = []
    private(set) var prescriptions: [Prescription] = []
    /// Nur Patient: eigenes Profil und eigene Aufträge
    private(set) var currentPatient: Patient?
    private(set) var myOrders: [Order] = []

    // MARK: - Einstellungen

    var isDarkMode: Bool = UserDefaults.standard.bool(forKey: Keys.darkMode) {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: Keys.darkMode) }
    }

    var language: AppLanguage = AppLanguage.savedOrDevice {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
            AppLanguage.current = language
        }
    }

    var notificationsEnabled: Bool = UserDefaults.standard.object(forKey: Keys.notifications) as? Bool ?? true {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notifications) }
    }

    /// Mitarbeiter: Standort bei Einsätzen teilen (nil = noch nicht gefragt)
    var shareLocation: Bool? = UserDefaults.standard.object(forKey: Keys.shareLocation) as? Bool {
        didSet {
            UserDefaults.standard.set(shareLocation, forKey: Keys.shareLocation)
            updateTracking()
        }
    }

    /// Patient: Live-Standort des Mitarbeiters anzeigen (nil = noch nicht gefragt)
    var showLiveLocation: Bool? = UserDefaults.standard.object(forKey: Keys.showLiveLocation) as? Bool {
        didSet { UserDefaults.standard.set(showLiveLocation, forKey: Keys.showLiveLocation) }
    }

    // MARK: - Intern

    private let container: AppContainer
    private let notifier = OrderNotifier()
    private var authListener: ListenerHandle?
    private var profileListener: ListenerHandle?
    private var membershipListener: ListenerHandle?
    private var requestListener: ListenerHandle?
    private var roleListener: ListenerHandle?
    private var dataListeners: [ListenerHandle] = []
    /// "uid|orgId|rolle" der geladenen Daten, damit nicht unnötig neu geladen wird
    private var loadedDataKey: String?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
        AppLanguage.current = language
        authListener = container.auth.listenAuthState { [weak self] uid in
            self?.authChanged(uid)
        }
    }

    // MARK: - Abgeleitete Werte

    var role: UserRole? { membership?.role.userRole }

    var orgId: String? { membership?.orgId }

    var currentEmployee: Employee? { employee(id: userId) }

    /// Mitarbeiter hat einen angenommenen Auftrag
    var hasActiveOrder: Bool {
        guard let userId else { return false }
        return orders.contains { $0.state == .aktuell && $0.assignedEmployeeId == userId }
    }

    /// Einmal fragen, bevor der Standort zum ersten Mal geteilt wird
    var needsLocationConsent: Bool {
        role == .employee && hasActiveOrder && shareLocation == nil
    }

    func employee(id: String?) -> Employee? {
        guard let id, !id.isEmpty else { return nil }
        return employees.first { $0.id == id }
    }

    func patient(id: String?) -> Patient? {
        guard let id, !id.isEmpty else { return nil }
        return patients.first { $0.id == id }
    }

    func order(id: String?) -> Order? {
        guard let id, !id.isEmpty else { return nil }
        return (orders + myOrders).first { $0.id == id }
    }

    // MARK: - Aktionen

    func logout() {
        EmployeeLocationManager.shared.stopTracking()
        do {
            try container.auth.signOut()
        } catch {
            message = error.localizedDescription
        }
    }

    func updateStatus(_ status: StaffStatus) {
        guard let userId, let orgId else { return }
        Task {
            try? await container.employees.updateStatus(orgId: orgId, id: userId, status: status)
        }
    }

    func switchOrganization(to orgId: String) {
        guard let userId else { return }
        Task {
            do {
                try await container.users.setActiveOrg(uid: userId, orgId: orgId)
            } catch {
                message = tr("Wechsel fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }

    // Leitung kann nicht austreten, sonst hätte die Organisation niemanden mehr
    func leaveOrganization() {
        guard let userId, let membership, let orgId = membership.orgId else { return }
        if membership.role == .admin {
            message = tr("Als Leitung kannst du nicht austreten. Mach vorher jemand anderen zur Leitung.")
            return
        }
        Task {
            do {
                try await container.organizations.leave(uid: userId, orgId: orgId)
            } catch {
                message = tr("Austreten fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }

    // MARK: - Ablauf der Sitzung

    private func authChanged(_ uid: String?) {
        profileListener?.remove()
        membershipListener?.remove()
        requestListener?.remove()
        membershipListener = nil
        stopOrganization()
        userId = uid
        profile = nil
        memberships = []

        guard let uid else {
            session = .loggedOut
            return
        }
        session = .loading
        profileListener = container.users.listen(uid: uid) { [weak self] profile in
            self?.profileChanged(profile, uid: uid)
        }
        // Angenommene Beitrittsanfragen in eine Mitgliedschaft umwandeln
        requestListener = container.organizations.listenMyJoinRequests(uid: uid) { [weak self] requests in
            for request in requests where request.status == .accepted {
                Task { try? await self?.container.organizations.completeAcceptedRequest(uid: uid, request: request) }
            }
        }
    }

    private func profileChanged(_ profile: UserProfile?, uid: String) {
        self.profile = profile
        guard profile != nil else {
            membershipListener?.remove()
            membershipListener = nil
            stopOrganization()
            session = .missingProfile
            return
        }
        // Mitgliedschaften nur einmal beobachten, das Profil ändert sich öfter (z. B. activeOrgId)
        if membershipListener == nil {
            membershipListener = container.organizations.listenMemberships(uid: uid) { [weak self] list in
                self?.memberships = list
                self?.selectOrganization()
            }
        } else {
            selectOrganization()
        }
    }

    // Zuletzt gewählte Organisation, sonst die erste
    private func selectOrganization() {
        guard let uid = userId, let profile else { return }
        let active = memberships.first { $0.orgId == profile.activeOrgId } ?? memberships.first
        guard let active, let orgId = active.orgId else {
            stopOrganization()
            session = .needsOrganization
            return
        }
        // Gleiche Organisation wie vorher, nichts neu laden
        if orgId == membership?.orgId && roleListener != nil { return }

        stopOrganization()
        session = .loading
        // Die Rolle zählt so, wie sie in der Organisation steht (Leitung kann sie ändern)
        roleListener = container.organizations.listenMemberRole(orgId: orgId, uid: uid) { [weak self] role in
            self?.roleChanged(role, base: active, uid: uid, orgId: orgId)
        }
    }

    private func roleChanged(_ role: MemberRole?, base: Membership, uid: String, orgId: String) {
        guard let role else {
            // Aus der Organisation entfernt → eigenen Eintrag aufräumen, danach geht es weiter
            session = .loading
            Task { try? await container.organizations.leave(uid: uid, orgId: orgId) }
            return
        }
        var current = base
        current.role = role
        membership = current
        container.currentOrgId = orgId
        startData(uid: uid, orgId: orgId, role: role.userRole)
        session = .loggedIn
    }

    private func stopOrganization() {
        roleListener?.remove()
        roleListener = nil
        stopData()
        membership = nil
        container.currentOrgId = nil
    }

    // MARK: - Live-Daten

    private func startData(uid: String, orgId: String, role: UserRole) {
        let key = "\(uid)|\(orgId)|\(role.rawValue)"
        guard key != loadedDataKey else { return }
        stopData()
        loadedDataKey = key

        dataListeners.append(container.employees.listenAll(orgId: orgId) { [weak self] in self?.employees = $0 })

        switch role {
        case .employee:
            dataListeners += [
                container.patients.listenAll(orgId: orgId) { [weak self] in self?.patients = $0 },
                container.orders.listenAll(orgId: orgId) { [weak self] list in
                    self?.ordersChanged(list, uid: uid)
                },
                container.prescriptions.listenAll(orgId: orgId) { [weak self] list in
                    self?.prescriptionsChanged(list, orgId: orgId)
                }
            ]
        case .patient:
            dataListeners += [
                container.patients.listen(orgId: orgId, id: uid) { [weak self] in self?.currentPatient = $0 },
                container.orders.listen(orgId: orgId, patientId: uid) { [weak self] list in
                    self?.myOrdersChanged(list, uid: uid)
                }
            ]
        }
    }

    private func stopData() {
        dataListeners.forEach { $0.remove() }
        dataListeners = []
        loadedDataKey = nil
        notifier.reset()
        employees = []
        patients = []
        orders = []
        prescriptions = []
        currentPatient = nil
        myOrders = []
        updateTracking()
    }

    private func ordersChanged(_ list: [Order], uid: String) {
        orders = list
        // Nur wer gerade arbeitet, bekommt etwas
        let working = currentEmployee?.currentStatus.isWorking ?? false
        notifier.ordersChanged(list, uid: uid, allowed: notificationsEnabled && working)
        updateTracking()
    }

    private func prescriptionsChanged(_ list: [Prescription], orgId: String) {
        prescriptions = list
        let working = currentEmployee?.currentStatus.isWorking ?? false
        notifier.prescriptionsChanged(list, orgId: orgId, allowed: notificationsEnabled && working)
    }

    private func myOrdersChanged(_ list: [Order], uid: String) {
        myOrders = list
        notifier.myOrdersChanged(list, uid: uid, allowed: notificationsEnabled) { [weak self] employeeId in
            self?.employee(id: employeeId)?.name.ifBlank(tr("Ein Mitarbeiter")) ?? tr("Ein Mitarbeiter")
        }
    }

    // MARK: - Standort

    /// Standort nur teilen, solange ein Auftrag angenommen ist und der Mitarbeiter zugestimmt hat
    func updateTracking() {
        let tracker = EmployeeLocationManager.shared
        guard let userId, let orgId, role == .employee, shareLocation == true, hasActiveOrder else {
            if tracker.isTracking { tracker.stopTracking() }
            return
        }
        tracker.startTracking(for: userId, orgId: orgId)
    }

    // MARK: - Schlüssel für UserDefaults

    fileprivate enum Keys {
        static let darkMode = "isDarkMode"
        static let language = "appLanguage"
        static let notifications = "notificationsEnabled"
        static let shareLocation = "shareLocation"
        static let showLiveLocation = "showLiveLocation"
    }
}

/// Sprache beim Start
extension AppLanguage {
    /// Gespeicherte Sprache, sonst die vom iPhone
    static var savedOrDevice: AppLanguage {
        guard let code = UserDefaults.standard.string(forKey: AppStateViewModel.Keys.language) else { return .device }
        return from(code: code)
    }
}
