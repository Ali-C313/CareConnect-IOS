//
//  Patient.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import FirebaseFirestore

struct Medication: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
}

struct EmergencyContact: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var relation: String
    var phone: String?
    var email: String?
    var address: String?
    var age: Int?
}

struct Patient: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var address: String
    var phone: String
    var birthDate: Date?
    var notes: String?
    var profileImageURL: String?   // neu

    // UI-Zusatz
    var medications: [Medication] = []
    var history: [String] = []

    // Computed
    var name: String { "\(firstName) \(lastName)" }

    var city: String {
        let parts = address.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return parts.last ?? ""
    }

    var age: Int {
        guard let birthDate else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
}
