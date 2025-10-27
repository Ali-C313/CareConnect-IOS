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
    var relation: String?
    var phone: String?
    var email: String?
    var address: String?
    var age: Int?
}

struct Patient: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String? // Firebase User UID for matching Orders
    var firstName: String?
    var lastName: String?
    var address: String?
    var phone: String?
    var email: String?
    var allergies: String?
    var medicalHistory: String?
    var age: Int?
    var birthDate: Date?
    var notes: String?
    var profileImageURL: String?   // neu

    // UI-Zusatz
    var medications: [Medication] = []
    var history: [String] = []
    var emergencyContact: EmergencyContact?

    // Computed
    var name: String { [firstName, lastName].compactMap { $0 }.joined(separator: " ") }

    var city: String?

    init(
        id: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        address: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        allergies: String? = nil,
        medicalHistory: String? = nil,
        age: Int? = nil,
        birthDate: Date? = nil,
        notes: String? = nil,
        profileImageURL: String? = nil,
        medications: [Medication] = [],
        history: [String] = [],
        emergencyContact: EmergencyContact? = nil,
        city: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.phone = phone
        self.email = email
        self.allergies = allergies
        self.medicalHistory = medicalHistory
        self.age = age
        self.birthDate = birthDate
        self.notes = notes
        self.profileImageURL = profileImageURL
        self.medications = medications
        self.history = history
        self.emergencyContact = emergencyContact
        self.city = city
    }
}
