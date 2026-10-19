//
//  PatientProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Medikamente, Termine und Karte zum Patientenprofil (Patient selbst kommt aus dem AppStateViewModel)
@MainActor
@Observable
final class PatientProfileViewModel {
    /// Medikamente, die der Patient selbst in seiner App pflegt
    private(set) var medicines: [MedicineEntry] = []
    private(set) var appointments: [AppointmentEntry] = []
    private(set) var coordinate: CLLocationCoordinate2D?
    private(set) var isLoadingLocation = false
    var errorMessage: String?

    private let container: AppContainer
    private var listeners: [ListenerHandle] = []
    private var lastAddress: String?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Nur kommende Termine
    var upcomingAppointments: [AppointmentEntry] {
        appointments
            .filter { $0.date.date >= Date() }
            .sorted { $0.date.date < $1.date.date }
    }

    func startListening(patientId: String) {
        guard listeners.isEmpty, let orgId = container.currentOrgId, !patientId.isEmpty else { return }
        listeners = [
            container.medicines.listen(orgId: orgId, patientId: patientId) { [weak self] in self?.medicines = $0 },
            container.appointments.listen(orgId: orgId, patientId: patientId) { [weak self] in self?.appointments = $0 }
        ]
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners = []
    }

    /// Adresse → Koordinate für die Karte
    func loadCoordinate(address: String) {
        guard address != lastAddress else { return }
        lastAddress = address
        isLoadingLocation = true
        Task {
            coordinate = await container.geo.coordinate(for: address)
            isLoadingLocation = false
        }
    }

    func saveEmergencyContact(_ contact: EmergencyContact, patientId: String) async -> Bool {
        do {
            let orgId = try container.requireOrgId()
            try await container.patients.saveEmergencyContact(orgId: orgId, id: patientId, contact: contact)
            return true
        } catch {
            errorMessage = tr("Speichern fehlgeschlagen: {0}", error.localizedDescription)
            return false
        }
    }
}
