//
//  MockOrderRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Aufträge aus den Beispieldaten
final class MockOrderRepository: OrderRepository {
    private var orders = MockData.orders

    func listenAll(orgId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle {
        onChange(orders)
        return MockListener()
    }

    func listen(orgId: String, id: String, onChange: @escaping (Order?) -> Void) -> ListenerHandle {
        onChange(orders.first { $0.id == id })
        return MockListener()
    }

    func listen(orgId: String, patientId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle {
        onChange(orders.filter { $0.patientId == patientId })
        return MockListener()
    }

    func create(_ order: Order, orgId: String) async throws {
        var newOrder = order
        newOrder.documentId = order.documentId ?? UUID().uuidString
        orders.insert(newOrder, at: 0)
    }

    func createMany(_ orders: [Order], orgId: String) async throws {
        for order in orders {
            try await create(order, orgId: orgId)
        }
    }

    func update(orgId: String, id: String, fields: [String: Any]) async throws {}

    func accept(orgId: String, id: String, employeeId: String) async throws {
        guard let index = orders.firstIndex(where: { $0.id == id }) else { return }
        orders[index].state = .aktuell
        orders[index].employeeId = employeeId
    }

    func complete(orgId: String, id: String, report: CompletionReport) async throws {
        guard let index = orders.firstIndex(where: { $0.id == id }) else { return }
        orders[index].state = .erledigt
        orders[index].report = report
    }

    func delete(orgId: String, id: String) async throws {
        orders.removeAll { $0.id == id }
    }
}
