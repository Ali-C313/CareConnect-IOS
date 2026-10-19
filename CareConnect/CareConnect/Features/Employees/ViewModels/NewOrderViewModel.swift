//
//  NewOrderViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Auftrag anlegen oder bearbeiten
@MainActor
@Observable
final class NewOrderViewModel {
    var patientId = ""
    var descriptionText = ""
    var dueDate = Date()
    var errorMessage: String?
    private(set) var isSaving = false

    let existingOrder: Order?
    private let orders: OrderRepository
    private let container: AppContainer

    init(existingOrder: Order? = nil, container: AppContainer? = nil) {
        let container = container ?? .shared
        self.existingOrder = existingOrder
        self.container = container
        self.orders = container.orders

        if let order = existingOrder {
            patientId = order.patientId ?? ""
            descriptionText = order.description
            dueDate = order.dueDate?.date ?? Date()
        }
    }

    var isEditing: Bool { existingOrder != nil }

    var canSave: Bool { !patientId.isEmpty && !descriptionText.isBlank && !isSaving }

    /// true wenn gespeichert
    func save(patient: Patient?, creatorId: String?) async -> Bool {
        guard let patient, let patientId = patient.id else {
            errorMessage = tr("Fehler: Patient nicht gefunden.")
            return false
        }
        isSaving = true
        defer { isSaving = false }

        do {
            let orgId = try container.requireOrgId()
            if let existingOrder {
                try await orders.update(orgId: orgId, id: existingOrder.id, fields: [
                    "patientId": patientId,
                    "patientName": patient.name,
                    "description": descriptionText.trimmed,
                    "dueDate": Timestamp(date: dueDate)
                ])
            } else {
                let order = Order(
                    description: descriptionText.trimmed,
                    patientId: patientId,
                    patientName: patient.name,
                    createdBy: creatorId ?? "",
                    employeeId: "",
                    dueDate: Timestamp(date: dueDate),
                    createdAt: Timestamp()
                )
                try await orders.create(order, orgId: orgId)
            }
            return true
        } catch {
            errorMessage = tr("Fehler beim Speichern: {0}", error.localizedDescription)
            return false
        }
    }
}
