//
//  AppointmentEntry.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Termin des Patienten (patients/{id}/appointments)
struct AppointmentEntry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var what: String = ""
    var address: String = ""
    var date: Timestamp = Timestamp()
    var bringItems: [String]?
    var notes: String?
}
