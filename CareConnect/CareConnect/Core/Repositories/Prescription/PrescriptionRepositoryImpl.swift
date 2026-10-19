//
//  PrescriptionRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

final class PrescriptionRepositoryImpl: PrescriptionRepository {
    private var database: Firestore { FirebaseManager.shared.database }

    private func ref(_ orgId: String) -> CollectionReference {
        database.org(orgId).collection(CollectionNames.prescriptions)
    }

    private func patientRef(_ orgId: String, _ patientId: String) -> DocumentReference {
        database.org(orgId).collection(CollectionNames.patients).document(patientId)
    }

    func listenAll(orgId: String, onChange: @escaping ([Prescription]) -> Void) -> ListenerHandle {
        ref(orgId).listen(as: Prescription.self) { list in
            onChange(list.sorted { ($0.createdAt?.date ?? .distantPast) > ($1.createdAt?.date ?? .distantPast) })
        }
    }

    func create(_ prescription: Prescription) async throws {
        let id = prescription.id ?? newId()
        let batch = database.batch()
        try batch.setData(from: prescription, forDocument: ref(prescription.fromOrgId).document(id))
        try batch.setData(from: prescription, forDocument: ref(prescription.toOrgId).document(id))
        try await batch.commit()
    }

    // Status in beiden Kopien ändern
    func updateStatus(_ prescription: Prescription, status: PrescriptionStatus, orderId: String?) async throws {
        guard let id = prescription.id else { throw AppError.missingId }
        let batch = database.batch()
        for orgId in [prescription.fromOrgId, prescription.toOrgId] {
            batch.updateData([
                "status": status.rawValue,
                "orderId": orderId ?? prescription.orderId
            ], forDocument: ref(orgId).document(id))
        }
        try await batch.commit()
    }

    func withdraw(_ prescription: Prescription) async throws {
        guard let id = prescription.id else { throw AppError.missingId }
        let batch = database.batch()
        batch.deleteDocument(ref(prescription.fromOrgId).document(id))
        batch.deleteDocument(ref(prescription.toOrgId).document(id))
        try await batch.commit()
    }

    func listenLinkedOrgs(orgId: String, patientId: String, onChange: @escaping ([LinkedOrg]) -> Void) -> ListenerHandle {
        patientRef(orgId, patientId).listen(as: Patient.self) { patient in
            onChange(patient?.linkedOrgs ?? [])
        }
    }

    func setLinkedOrgs(_ links: [LinkedOrg], orgId: String, patientId: String) async throws {
        try await patientRef(orgId, patientId).setData([
            "linkedOrgIds": links.map(\.orgId),
            "linkedOrgs": links.map { ["orgId": $0.orgId, "orgName": $0.orgName] }
        ], merge: true)
    }
}
