//
//  EmployeeRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseFirestore

protocol EmployeeRepository {
    func fetch(by id: String) async throws -> Employee
    func update(id: String, fields: [String: Any]) async throws
}

final class FirebaseEmployeeRepository: EmployeeRepository {
    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("employees") }

    func fetch(by id: String) async throws -> Employee {
        try await ref.document(id).getDocument(as: Employee.self)
    }

    func update(id: String, fields: [String: Any]) async throws {
        try await ref.document(id).setData(fields, merge: true)
    }
}
