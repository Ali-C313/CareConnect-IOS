//
//  AppContainer.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Alle Repositories an einer Stelle.
/// In der App laufen die Firebase-Repositories, in den Xcode-Previews die Mock-Repositories.
final class AppContainer {
    static let shared: AppContainer = isPreview ? .mock : .live

    let auth: AuthRepository
    let users: UserRepository
    let organizations: OrganizationRepository
    let employees: EmployeeRepository
    let patients: PatientRepository
    let orders: OrderRepository
    let medicines: MedicineRepository
    let appointments: AppointmentRepository
    let locations: LocationRepository
    let prescriptions: PrescriptionRepository
    let storage: StorageRepository
    let geo = GeoService()

    /// Organisation, in der gerade gearbeitet wird (setzt das AppStateViewModel)
    var currentOrgId: String?

    init(
        auth: AuthRepository,
        users: UserRepository,
        organizations: OrganizationRepository,
        employees: EmployeeRepository,
        patients: PatientRepository,
        orders: OrderRepository,
        medicines: MedicineRepository,
        appointments: AppointmentRepository,
        locations: LocationRepository,
        prescriptions: PrescriptionRepository,
        storage: StorageRepository
    ) {
        self.auth = auth
        self.users = users
        self.organizations = organizations
        self.employees = employees
        self.patients = patients
        self.orders = orders
        self.medicines = medicines
        self.appointments = appointments
        self.locations = locations
        self.prescriptions = prescriptions
        self.storage = storage
    }

    /// Wirft einen Fehler, wenn keine Organisation gewählt ist
    func requireOrgId() throws -> String {
        guard let currentOrgId else { throw AppError.noOrganization }
        return currentOrgId
    }

    // MARK: - Varianten

    /// Echte Daten aus Firebase
    static var live: AppContainer {
        let storage = StorageRepositoryImpl()
        return AppContainer(
            auth: AuthRepositoryImpl(),
            users: UserRepositoryImpl(),
            organizations: OrganizationRepositoryImpl(),
            employees: EmployeeRepositoryImpl(storage: storage),
            patients: PatientRepositoryImpl(),
            orders: OrderRepositoryImpl(),
            medicines: MedicineRepositoryImpl(),
            appointments: AppointmentRepositoryImpl(),
            locations: LocationRepositoryImpl(),
            prescriptions: PrescriptionRepositoryImpl(),
            storage: storage
        )
    }

    /// Beispieldaten ohne Firebase, z. B. für Previews
    static var mock: AppContainer {
        AppContainer(
            auth: MockAuthRepository(),
            users: MockUserRepository(),
            organizations: MockOrganizationRepository(),
            employees: MockEmployeeRepository(),
            patients: MockPatientRepository(),
            orders: MockOrderRepository(),
            medicines: MockMedicineRepository(),
            appointments: MockAppointmentRepository(),
            locations: MockLocationRepository(),
            prescriptions: MockPrescriptionRepository(),
            storage: MockStorageRepository()
        )
    }

    /// Xcode setzt diese Variable, wenn eine Preview läuft
    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
