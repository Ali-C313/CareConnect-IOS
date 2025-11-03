//
//  Patient.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import FirebaseFirestore

/// Medikament Info
struct Medication: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
}

/// Notfallkontakt
struct EmergencyContact: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var relation: String?
    var phone: String?
    var email: String?
    var address: String?
    var age: Int?
}

/// Patientendaten
struct Patient: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String?
    var firstName: String?
    var lastName: String?
    var address: String?
    var phone: String?
    var email: String?
    var allergies: String?
    var medicalHistory: String?
    var age: Int?
    var birthDate: Timestamp?
    var notes: String?
    var profileImageURL: String?

    
    /// Medikamente
    var medications: [Medication]? = []
    /// Krankengeschichte
    var history: [String]? = []
    /// Notfallkontakt Info
    var emergencyContact: EmergencyContact? = nil

    
    var name: String {
        let first = (firstName ?? "").trimmingCharacters(in: .whitespaces)
        let last  = (lastName  ?? "").trimmingCharacters(in: .whitespaces)
        let full  = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        if !full.isEmpty { return full }
        return email ?? "Unbekannt"
    }

    var city: String?
}
