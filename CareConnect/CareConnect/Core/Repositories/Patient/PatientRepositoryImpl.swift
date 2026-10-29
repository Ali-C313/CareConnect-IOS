//
//  PatientRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Patienten in Firestore (organizations/{id}/patients)
final class PatientRepositoryImpl: PatientRepository {
    private func ref(_ orgId: String) -> CollectionReference {
        FirebaseManager.shared.database.org(orgId).collection(CollectionNames.patients)
    }

    func listenAll(orgId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerHandle {
        ref(orgId).listen(as: Patient.self) { patients in
            onChange(patients.sorted { $0.name < $1.name })
        }
    }

    func listen(orgId: String, id: String, onChange: @escaping (Patient?) -> Void) -> ListenerHandle {
        ref(orgId).document(id).listen(as: Patient.self, onChange: onChange)
    }

    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws {
        guard !id.isBlank else { throw AppError.missingId }
        try await ref(orgId).document(id).setData(fields, merge: true)
    }

    func saveEmergencyContact(orgId: String, id: String, contact: EmergencyContact) async throws {
        let encoded = try Firestore.Encoder().encode(contact)
        try await ref(orgId).document(id).setData(["emergencyContact": encoded], merge: true)
    }
}
