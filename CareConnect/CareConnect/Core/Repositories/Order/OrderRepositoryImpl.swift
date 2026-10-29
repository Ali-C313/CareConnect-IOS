//
//  OrderRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Aufträge in Firestore (organizations/{id}/orders)
final class OrderRepositoryImpl: OrderRepository {
    private var database: Firestore { FirebaseManager.shared.database }

    private func ref(_ orgId: String) -> CollectionReference {
        database.org(orgId).collection(CollectionNames.orders)
    }

    // Neueste zuerst
    private func sorted(_ orders: [Order]) -> [Order] {
        orders.sorted { ($0.createdAt?.date ?? .distantPast) > ($1.createdAt?.date ?? .distantPast) }
    }

    func listenAll(orgId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle {
        ref(orgId).listen(as: Order.self) { [weak self] orders in
            onChange(self?.sorted(orders) ?? orders)
        }
    }

    func listen(orgId: String, patientId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle {
        ref(orgId)
            .whereField("patientId", isEqualTo: patientId)
            .listen(as: Order.self) { [weak self] orders in
                onChange(self?.sorted(orders) ?? orders)
            }
    }

    func create(_ order: Order, orgId: String) async throws {
        let id = order.documentId ?? newId()
        try ref(orgId).document(id).setData(from: order)
    }

    func createMany(_ orders: [Order], orgId: String) async throws {
        // Firestore erlaubt max. 500 Schreibvorgänge pro Batch
        for start in stride(from: 0, to: orders.count, by: 400) {
            let batch = database.batch()
            for order in orders[start..<min(start + 400, orders.count)] {
                try batch.setData(from: order, forDocument: ref(orgId).document(order.documentId ?? newId()))
            }
            try await batch.commit()
        }
    }

    func update(orgId: String, id: String, fields: [String: Any]) async throws {
        guard !id.isBlank else { throw AppError.missingId }
        try await ref(orgId).document(id).updateData(fields)
    }

    func accept(orgId: String, id: String, employeeId: String) async throws {
        let orderRef = ref(orgId).document(id)
        let block = Self.acceptBlock(
            orderRef: orderRef,
            employeeId: employeeId,
            notFound: tr("Der Auftrag existiert nicht mehr."),
            taken: tr("Der Auftrag wurde schon von jemand anderem angenommen.")
        )
        _ = try await database.runTransaction(block)
    }

    // Läuft im Hintergrund, deshalb nonisolated und nur mit einfachen Werten
    nonisolated private static func acceptBlock(
        orderRef: DocumentReference,
        employeeId: String,
        notFound: String,
        taken: String
    ) -> (Transaction, NSErrorPointer) -> Any? {
        return { transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(orderRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            guard snapshot.exists else {
                errorPointer?.pointee = NSError(domain: "CareConnect", code: 404, userInfo: [NSLocalizedDescriptionKey: notFound])
                return nil
            }
            let state = (snapshot.data()?["state"] as? String)?.lowercased() ?? "offen"
            guard state == "offen" else {
                errorPointer?.pointee = NSError(domain: "CareConnect", code: 409, userInfo: [NSLocalizedDescriptionKey: taken])
                return nil
            }
            transaction.updateData(["state": "aktuell", "employeeId": employeeId], forDocument: orderRef)
            return nil
        }
    }

    func complete(orgId: String, id: String, report: CompletionReport) async throws {
        try await ref(orgId).document(id).updateData([
            "state": OrderState.erledigt.rawValue,
            "report.note": report.note,
            "report.signature": report.signature,
            "report.signedBy": report.signedBy,
            "report.completedAt": Timestamp(),
            "report.completedBy": report.completedBy,
            "report.completedByName": report.completedByName
        ])
    }

    func delete(orgId: String, id: String) async throws {
        try await ref(orgId).document(id).delete()
    }
}
