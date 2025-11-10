//
//  FirebaseOrderRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

final class FirebaseOrderRepository: OrderProtocol {
    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("orders") }
    private var ordersListener: ListenerRegistration?

    /// Live-Listener
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

    /// Auftrag erstellen
    func create(_ order: Order) async throws {
        let id = order.id ?? UUID().uuidString
        var o = order; o.id = id
        try ref.document(id).setData(from: o, merge: true)
    }

    /// Auftrag aktualisieren
    func update(id: String, fields: [String: Any]) async throws {
        try await ref.document(id).setData(fields, merge: true)
    }

    /// Aufträge laden
    func fetchAll() async throws -> [Order] {
        let snap = try await ref.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Order.self) }
    }
    
    /// Listener stoppen
    func stopListening() {
        ordersListener?.remove()
        ordersListener = nil
    }
}