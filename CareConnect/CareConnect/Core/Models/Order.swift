//
//  Order.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Auftrag, liegt unter organizations/{orgId}/orders
struct Order: Identifiable, Codable, Hashable {
    // Android speichert zusätzlich ein Feld "id", deshalb heißt die Dokument-ID hier anders
    @DocumentID var documentId: String?
    var state: OrderState = .offen
    var notes: [String]?
    var description: String = ""
    var patientId: String?
    var patientName: String?
    /// UID von dem, der den Auftrag angelegt hat
    var createdBy: String?
    /// Mitarbeiter, der den Auftrag angenommen hat
    var employeeId: String?
    /// Altes Feld aus der ersten iOS-Version
    var assignedTo: String?
    var dueDate: Timestamp?
    var createdAt: Timestamp?
    /// Leistungsnachweis beim Abschließen
    var report: CompletionReport?

    var id: String { documentId ?? "" }

    /// Zuständiger Mitarbeiter (neues oder altes Feld)
    var assignedEmployeeId: String {
        let value = employeeId ?? ""
        return value.isEmpty ? (assignedTo ?? "") : value
    }

    var displayTitle: String { tr("Auftrag #{0}", String(id.prefix(6))) }

    var displayPatientName: String { (patientName ?? "").ifBlank(tr("Unbekannter Patient")) }

    var notesText: String { (notes ?? []).joined(separator: ", ") }

    static let emergencyDescription = "Notfallauftrag"
}

/// Leistungsnachweis: was gemacht wurde und Unterschrift
struct CompletionReport: Codable, Hashable {
    var note: String = ""
    /// Striche als "x,y;x,y|x,y;..." mit Werten von 0 bis 1000, leer = keine Unterschrift
    var signature: String = ""
    var signedBy: String = ""
    var completedAt: Timestamp?
    var completedBy: String = ""
    var completedByName: String = ""
}
