//
//  AppointmentsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Termine des Patienten anzeigen, anlegen, bearbeiten und löschen
@MainActor
@Observable
final class AppointmentsViewModel {
    private(set) var appointments: [AppointmentEntry] = []
    var errorMessage: String?

    private let container: AppContainer
    private var listener: ListenerHandle?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    private var patientId: String? { container.auth.currentUserId }

    /// Nächster Termin zuerst
    var sortedAppointments: [AppointmentEntry] {
        appointments.sorted { $0.date.date < $1.date.date }
    }

    func startListening() {
        guard listener == nil, let patientId, let orgId = container.currentOrgId else { return }
        listener = container.appointments.listen(orgId: orgId, patientId: patientId) { [weak self] list in
            self?.appointments = list
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    /// Ohne ID neu anlegen, sonst überschreiben
    func save(_ appointment: AppointmentEntry) {
        guard let patientId else { return }
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.appointments.save(appointment, orgId: orgId, patientId: patientId)
            } catch {
                errorMessage = tr("Fehler beim Speichern: {0}", error.localizedDescription)
            }
        }
    }

    func delete(_ appointment: AppointmentEntry) {
        guard let patientId, let id = appointment.id else { return }
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.appointments.delete(id: id, orgId: orgId, patientId: patientId)
            } catch {
                errorMessage = tr("Löschen fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }
}
