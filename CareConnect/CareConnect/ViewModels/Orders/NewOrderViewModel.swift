//
//  NewOrderViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class NewOrderViewModel: ObservableObject {
    @Published var patientId = ""
    @Published var notes = ""
    @Published var dueDate = Date()
    @Published var isSaving = false
    @Published var error: String?

    private let orderRepo: OrderRepository

    init(orderRepo: OrderRepository = FirebaseOrderRepository()) { self.orderRepo = orderRepo }

    func save(creatorUID: String) async -> Bool {
        guard !patientId.isEmpty, !notes.isEmpty else { return false }
        isSaving = true; defer { isSaving = false }
        do {
            var order = Order(
                employeeId: "",
                patientId: patientId,
                notes: notes,
                state: .offen,
                documentFiles: [],
                date: dueDate
            )
            order.id = UUID().uuidString
            try await orderRepo.create(order)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }
}
