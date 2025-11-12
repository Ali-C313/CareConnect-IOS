//
//  FirebaseOrderRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

private func safeDecode<T: Decodable>(_ document: QueryDocumentSnapshot, as type: T.Type) -> T? {
    do {
        return try document.data(as: T.self)
    } catch {
        print("⚠️ Decode error in FirebaseOrderRepository for \(T.self): \(document.documentID) → \(error.localizedDescription)")
        return nil
    }
}

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
                    print("❌ Firestore listener failed: \(error.localizedDescription)")
                    onError(error)
                    return
                }

                guard let docs = snapshot?.documents else {
                    print("⚠️ No snapshot documents found for orders")
                    onChange([])
                    return
                }

                let orders = docs.compactMap { safeDecode($0, as: Order.self) }
                print("📡 Fetched \(orders.count) orders from Firestore.")
                onChange(orders)
            }
    }

    /// Auftrag erstellen
    func create(_ order: Order) async throws {
        let id = order.id ?? UUID().uuidString
        var newOrder = order; newOrder.id = id
        do {
            try ref.document(id).setData(from: newOrder, merge: true)
            print("✅ Order created with ID: \(id)")
        } catch {
            print("❌ Failed to create order (\(id)): \(error.localizedDescription)")
            throw error
        }
    }

    /// Auftrag aktualisieren
    func update(id: String, fields: [String: Any]) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Skipped update: empty document ID.")
            return
        }
        do {
            try await ref.document(id).setData(fields, merge: true)
            print("✅ Updated order \(id)")
        } catch {
            print("❌ Failed to update order \(id): \(error.localizedDescription)")
            throw error
        }
    }

    /// Aufträge laden
    func fetchAll() async throws -> [Order] {
        do {
            let snap = try await ref.getDocuments()
            return snap.documents.compactMap { safeDecode($0, as: Order.self) }
        } catch {
            print("❌ Firestore fetchAll failed:", error.localizedDescription)
            return []
        }
    }
    
    /// Listener stoppen
    func stopListening() {
        ordersListener?.remove()
        ordersListener = nil
    }

    func delete(id: String) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Skip delete: invalid ID")
            return
        }
        do {
            try await ref.document(id).delete()
            print("🗑️ Order deleted: \(id)")
        } catch {
            print("❌ Failed to delete order (\(id)): \(error.localizedDescription)")
            throw error
        }
    }
}
