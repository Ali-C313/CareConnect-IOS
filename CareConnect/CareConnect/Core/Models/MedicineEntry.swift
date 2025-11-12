//
//  MedicineEntry.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import Foundation
import FirebaseFirestore

struct MedicineEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var dosage: String
    var timeOfDay: TimeOfDay
}

enum TimeOfDay: String, CaseIterable, Codable {
    case morning = "Morgens"
    case noon = "Mittags"
    case evening = "Abends"
}
