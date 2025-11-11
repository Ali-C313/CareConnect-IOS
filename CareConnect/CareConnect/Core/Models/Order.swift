//
//  Order.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore


/// PDF-Datei Info
struct DocumentFile: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var fileName: String
}

/// Auftragsdaten
struct Order: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var state: OrderState
    var notes: [String]? = []
    var description: String
    var patientName: String
    var createdBy: String
    var assignedTo: String?
    /// Mitarbeiter-ID
    var employeeId: String?
    var dueDate: Timestamp?
    var createdAt: Timestamp?

    init(
        state: OrderState,
        notes: [String]? = [],
        description: String,
        patientName: String,
        createdBy: String,
        assignedTo: String? = nil,
        employeeId: String? = nil,
        dueDate: Timestamp,
        createdAt: Timestamp
    ) {
        self.id = nil
        self.state = state
        self.notes = notes
        self.description = description
        self.patientName = patientName
        self.createdBy = createdBy
        self.assignedTo = assignedTo
        self.employeeId = employeeId
        self.dueDate = dueDate
        self.createdAt = createdAt
    }

    var isActive: Bool { state == .aktuell }
    var displayTitle: String { "Auftrag #\((id ?? "Unbekannt").prefix(6))" }
}
