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
    /// Ladezustand
    @Published var isProcessing = false
    /// Fehlermeldung
    @Published var error: String?

    private let orderRepo: OrderProtocol

    /// Initialisiert Repo
    init(orderRepo: OrderProtocol? = nil) {
        self.orderRepo = orderRepo ?? FirebaseOrderRepository()
    }

    /// Auftrag annehmen
    func accept(order: Order, by employeeId: String) async {
        guard let id = order.id else { return }
        isProcessing = true; defer { isProcessing = false }
        do {
            try await orderRepo.update(id: id, fields: [
                "state": OrderState.aktuell.rawValue,
                "employeeId": employeeId,
                "acceptedAt": Date()
            ])
            EmployeeLocationManager.shared.startTracking(for: employeeId, orderId: id)
        } catch { self.error = "Fehler beim Annehmen: \(error.localizedDescription)" }
    }

    /// Auftrag abschließen
    func complete(order: Order) async {
        guard let id = order.id else { return }
        isProcessing = true; defer { isProcessing = false }
        do {
            try await orderRepo.update(id: id, fields: [
                "state": OrderState.erledigt.rawValue,
                "completedAt": Date()
            ])
            EmployeeLocationManager.shared.stopTracking()
        } catch { self.error = "Fehler beim Abschließen: \(error.localizedDescription)" }
    }
}
