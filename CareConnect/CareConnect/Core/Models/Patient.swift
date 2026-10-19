//
//  Patient.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Medikament aus der alten Kurzliste am Patienten
struct Medication: Identifiable, Codable, Hashable {
    var id: String?
    var name: String = ""
}

/// Notfallkontakt
struct EmergencyContact: Codable, Hashable {
    var name: String = ""
    var relation: String = ""
    var phone: String = ""
    var email: String = ""
    var address: String = ""
    var age: Int?
}

/// Pflegedienst, an den eine Praxis Verordnungen schicken darf
struct LinkedOrg: Identifiable, Codable, Hashable {
    var orgId: String
    var orgName: String = ""

    var id: String { orgId }
}

/// Patient einer Organisation, Feldnamen wie in der Android-App
struct Patient: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String?
    var firstName: String?
    var lastName: String?
    var address: String?
    var city: String?
    var phone: String?
    var email: String?
    var allergies: String?
    var medicalHistory: String?
    var age: Int?
    var birthDate: Timestamp?
    var notes: String?
    var profileImageURL: String?
    var medications: [Medication]?
    var history: [String]?
    var emergencyContact: EmergencyContact?
    var createdAt: Timestamp?
    var linkedOrgIds: [String]?
    var linkedOrgs: [LinkedOrg]?

    /// Vor- und Nachname, sonst E-Mail
    var name: String {
        let full = [firstName, lastName]
            .compactMap { $0?.trimmed }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !full.isEmpty { return full }
        return (email ?? "").ifBlank(tr("Unbekannt"))
    }

    var initials: String { name.initials }

    /// Adresse + Stadt in einer Zeile, leer wenn nichts da ist
    var fullAddress: String {
        [address, city]
            .compactMap { $0?.trimmed }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
