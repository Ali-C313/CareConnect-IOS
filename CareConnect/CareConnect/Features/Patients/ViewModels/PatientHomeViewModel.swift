//
//  PatientHomeViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Notfallauftrag vom Home-Screen des Patienten
@MainActor
@Observable
final class PatientHomeViewModel {
    var message: String?

    private let container: AppContainer

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Dringender Auftrag für den Pflegedienst
    func createEmergencyOrder(patientName: String) {
        guard let uid = container.auth.currentUserId else { return }
        let order = Order(
            state: .offen,
            notes: [tr("Automatisch generierter Notfallauftrag")],
            // Bleibt deutsch, damit beide Apps den Notfall erkennen
            description: Order.emergencyDescription,
            patientId: uid,
            patientName: patientName,
            createdBy: uid,
            employeeId: "",
            dueDate: Timestamp(),
            createdAt: Timestamp()
        )
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.orders.create(order, orgId: orgId)
                message = tr("Der Notfallauftrag wurde erstellt. Ein Mitarbeiter kümmert sich darum.")
            } catch {
                message = tr("Fehler beim Erstellen des Notfallauftrags: {0}", error.localizedDescription)
            }
        }
    }
}
