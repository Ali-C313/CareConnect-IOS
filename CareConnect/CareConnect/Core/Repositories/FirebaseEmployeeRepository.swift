//
//  FirebaseEmployeeRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseFirestore

final class FirebaseEmployeeRepository: EmployeeProtocol {
    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("employees") }

    /// Mitarbeiter laden
    func fetch(by id: String) async throws -> Employee {
        try await ref.document(id).getDocument(as: Employee.self)
    }

    /// Mitarbeiter aktualisieren
    func update(id: String, fields: [String: Any]) async throws {
        try await ref.document(id).setData(fields, merge: true)
    }
}
