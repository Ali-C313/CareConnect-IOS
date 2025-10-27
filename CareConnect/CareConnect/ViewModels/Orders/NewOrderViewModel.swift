//
//  NewOrderViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class NewOrderViewModel: ObservableObject {
    @Published var patientId = ""
    @Published var notes = ""
    @Published var dueDate = Date()
    @Published var isSaving = false
    @Published var error: String?

    private let orderRepo: OrderRepository

    init(orderRepo: OrderRepository? = nil) {
        self.orderRepo = orderRepo ?? FirebaseOrderRepository()
    }

    func save(creatorUID: String) async -> Bool {
        guard !patientId.isEmpty, !notes.isEmpty else { return false }
        isSaving = true; defer { isSaving = false }
        do {
            let order = Order(
                state: .offen,
                notes: [notes],
                description: "Auftrag", // Falls kein eigener Beschreibungstext vorhanden
                patientName: "", // Anzeige optional
                createdBy: creatorUID,
                assignedTo: patientId, // Patient UID korrekt zugeordnet
                dueDate: Timestamp(date: dueDate),
                createdAt: Timestamp(date: Date())
            )
            try await orderRepo.create(order)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }
}
