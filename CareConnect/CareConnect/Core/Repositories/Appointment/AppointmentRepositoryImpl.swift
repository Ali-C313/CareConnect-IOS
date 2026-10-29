//
//  AppointmentRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Termine in Firestore (patients/{id}/appointments)
final class AppointmentRepositoryImpl: AppointmentRepository {
    private func ref(_ orgId: String, _ patientId: String) -> CollectionReference {
        FirebaseManager.shared.database.org(orgId)
            .collection(CollectionNames.patients)
            .document(patientId)
            .collection(CollectionNames.appointments)
    }

    func listen(orgId: String, patientId: String, onChange: @escaping ([AppointmentEntry]) -> Void) -> ListenerHandle {
        ref(orgId, patientId).listen(as: AppointmentEntry.self) { appointments in
            onChange(appointments.sorted { $0.date.date < $1.date.date })
        }
    }

    func save(_ appointment: AppointmentEntry, orgId: String, patientId: String) async throws {
        if let id = appointment.id {
            try ref(orgId, patientId).document(id).setData(from: appointment)
        } else {
            try ref(orgId, patientId).addDocument(from: appointment)
        }
    }

    func delete(id: String, orgId: String, patientId: String) async throws {
        try await ref(orgId, patientId).document(id).delete()
    }
}
