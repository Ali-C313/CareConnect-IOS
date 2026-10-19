//
//  MedicineEntry.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Medikament des Patienten (patients/{id}/medicines)
struct MedicineEntry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String = ""
    var dosage: String = ""
    var timeOfDay: TimeOfDay = .morning
}
