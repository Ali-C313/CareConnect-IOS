//
//  PatientRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseFirestore

protocol PatientRepository {
    func fetch(by id: String) async throws -> Patient
    func fetchAll() async throws -> [Patient]
}

final class FirebasePatientRepository: PatientRepository {
    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("patients") }

    func fetch(by id: String) async throws -> Patient {
        try await ref.document(id).getDocument(as: Patient.self)
    }

    func fetchAll() async throws -> [Patient] {
        let snap = try await ref.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Patient.self) }
    }
}
