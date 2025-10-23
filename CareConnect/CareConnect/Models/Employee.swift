//
//  Employee.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import FirebaseFirestore

struct Employee: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var role: String
    var status: String?                  // z. B. "Verfügbar"
    var email: String
    var birthDate: Date?                 // neu
    var profileImageURL: String?         // neu

    var name: String { "\(firstName) \(lastName)" }

    var staffStatusEnum: StaffStatus {
        StaffStatus(rawValue: status ?? StaffStatus.available.rawValue) ?? .available
    }
}
