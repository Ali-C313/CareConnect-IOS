//
//  AppointmentEntry.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct AppointmentEntry: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var what: String            // Wo/Was (z. B. „Arzttermin – Orthopädie“)
    var address: String         // Adresse
    var date: Date              // Datum + Uhrzeit in einem Feld
    var bringItems: [String]    // z. B. ["Ausweis", "Krankenkassenkarte"]
    var notes: String?          // optionale Bemerkung

    init(
        what: String,
        address: String,
        date: Date,
        bringItems: [String] = [],
        notes: String? = nil
    ) {
        self.what = what
        self.address = address
        self.date = date
        self.bringItems = bringItems
        self.notes = notes
    }

    /// Flag für Hervorhebung in der Liste
    var hasImportantItems: Bool {
        !bringItems.isEmpty
    }
}
