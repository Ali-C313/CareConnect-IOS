//
//  OrderDetailViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class OrderDetailViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var error: String?

    private let orderRepo: OrderRepository

    init(orderRepo: OrderRepository? = nil) {
        self.orderRepo = orderRepo ?? FirebaseOrderRepository()
    }

    func accept(order: Order, by employeeId: String) async {
        guard let id = order.id else { return }
        isProcessing = true; defer { isProcessing = false }
        do { try await orderRepo.update(id: id, fields: [
                "state": OrderState.aktuell.rawValue,
                "employeeId": employeeId,
                "acceptedAt": Date()
            ])
        } catch { self.error = "Fehler beim Annehmen: \(error.localizedDescription)" }
    }

    func complete(order: Order) async {
        guard let id = order.id else { return }
        isProcessing = true; defer { isProcessing = false }
        do { try await orderRepo.update(id: id, fields: [
                "state": OrderState.erledigt.rawValue,
                "completedAt": Date()
            ])
        } catch { self.error = "Fehler beim Abschließen: \(error.localizedDescription)" }
    }
}
