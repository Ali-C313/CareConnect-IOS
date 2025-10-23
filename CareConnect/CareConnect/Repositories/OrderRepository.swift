//
//  OrderRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseFirestore

protocol OrderRepository {
    func create(_ order: Order) async throws
    func update(id: String, fields: [String: Any]) async throws
    func fetchAll() async throws -> [Order]
}

final class FirebaseOrderRepository: OrderRepository {
    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("orders") }

    func create(_ order: Order) async throws {
        let id = order.id ?? UUID().uuidString
        var o = order; o.id = id
        try await ref.document(id).setData(from: o, merge: true)
    }

    func update(id: String, fields: [String: Any]) async throws {
        try await ref.document(id).setData(fields, merge: true)
    }

    func fetchAll() async throws -> [Order] {
        let snap = try await ref.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Order.self) }
    }
}
