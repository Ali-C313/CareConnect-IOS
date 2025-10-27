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
    private var ordersListener: ListenerRegistration?

    func listenToAllOrders(onChange: @escaping ([Order]) -> Void,
                           onError: @escaping (Error) -> Void) {
        ordersListener?.remove()
        ordersListener = ref
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }
                print("✅ Listener triggered — no Firestore error")
                guard let docs = snapshot?.documents else {
                    onChange([])
                    return
                }
                print("📡 Snapshot received:")
                print("Documents count: \(docs.count)")
                for doc in docs {
                    print("→ Doc ID: \(doc.documentID)")
                    print("  Data: \(doc.data())")
                }
                let items: [Order] = docs.compactMap { doc in
                    return try? doc.data(as: Order.self)
                }
                onChange(items)
            }
    }

    func create(_ order: Order) async throws {
        let id = order.id ?? UUID().uuidString
        var o = order; o.id = id
        try ref.document(id).setData(from: o, merge: true)
    }

    func update(id: String, fields: [String: Any]) async throws {
        try await ref.document(id).setData(fields, merge: true)
    }

    func fetchAll() async throws -> [Order] {
        let snap = try await ref.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Order.self) }
    }
    
    func stopListening() {
        ordersListener?.remove()
        ordersListener = nil
    }
}
