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
    var status: String?
    var email: String
    var birthDate: Date?
    var profileImageURL: String?

    /// Vollständiger Name
    var name: String { "\(firstName) \(lastName)" }

    /// Status als Enum
    var staffStatusEnum: StaffStatus {
        StaffStatus(rawValue: status ?? StaffStatus.available.rawValue) ?? .available
    }
}
