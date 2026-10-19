//
//  MedicineRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

final class MedicineRepositoryImpl: MedicineRepository {
    private func ref(_ orgId: String, _ patientId: String) -> CollectionReference {
        FirebaseManager.shared.database.org(orgId)
            .collection(CollectionNames.patients)
            .document(patientId)
            .collection(CollectionNames.medicines)
    }

    func listen(orgId: String, patientId: String, onChange: @escaping ([MedicineEntry]) -> Void) -> ListenerHandle {
        ref(orgId, patientId).listen(as: MedicineEntry.self, onChange: onChange)
    }

    func add(_ medicine: MedicineEntry, orgId: String, patientId: String) async throws {
        try ref(orgId, patientId).addDocument(from: medicine)
    }

    func delete(id: String, orgId: String, patientId: String) async throws {
        try await ref(orgId, patientId).document(id).delete()
    }
}
