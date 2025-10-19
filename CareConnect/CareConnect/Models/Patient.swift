//
//  Patient.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation

struct Medication: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
}

struct EmergencyContact: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var relation: String
    var phone: String?
    var email: String?
    var address: String?
    var age: Int?
}

struct Patient: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var age: Int
    var city: String
    var address: String?
    var phone: String?
    var email: String?
    var medications: [Medication] = []
    var history: [String] = []
    var emergency: EmergencyContact? = nil
    var avatarURL: String? = nil
}
