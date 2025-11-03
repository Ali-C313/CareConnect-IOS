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
    /// Patient-ID
    @Published var patientId = ""
    /// Notizen
    @Published var notes = ""
    /// Fälligkeitsdatum
    @Published var dueDate = Date()
    /// Speicherstatus
    @Published var isSaving = false
    /// Fehlermeldung
    @Published var error: String?

    private let orderRepo: OrderProtocol

    /// Initialisiert Repo
    init(orderRepo: OrderProtocol? = nil) {
        self.orderRepo = orderRepo ?? FirebaseOrderRepository()
    }

    /// Auftrag speichern
    func save(creatorUID: String) async -> Bool {
        guard !patientId.isEmpty, !notes.isEmpty else { return false }
        isSaving = true; defer { isSaving = false }
        do {
            let order = Order(
                state: .offen,
                notes: [notes],
                description: "Auftrag",
                patientName: "",
                createdBy: creatorUID,
                assignedTo: patientId,
                dueDate: Timestamp(date: dueDate),
                createdAt: Timestamp(date: Date())
            )
            try await orderRepo.create(order)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }
}
