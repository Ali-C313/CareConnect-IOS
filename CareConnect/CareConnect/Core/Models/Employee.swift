//
//  Employee.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Arbeitszeiten eines Mitarbeiters
struct WorkSchedule: Codable, Hashable {
    var weeklyHours: Int = 40
    var shiftStart: String = "08:00"
    var shiftEnd: String = "16:30"
    var workDays: [String] = ["Mo", "Di", "Mi", "Do", "Fr"]

    init() {}

    // Fehlende Felder bekommen den Standardwert
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weeklyHours = try container.decodeIfPresent(Int.self, forKey: .weeklyHours) ?? 40
        shiftStart = try container.decodeIfPresent(String.self, forKey: .shiftStart) ?? "08:00"
        shiftEnd = try container.decodeIfPresent(String.self, forKey: .shiftEnd) ?? "16:30"
        workDays = try container.decodeIfPresent([String].self, forKey: .workDays) ?? ["Mo", "Di", "Mi", "Do", "Fr"]
    }
}

/// Mitarbeiter einer Organisation
struct Employee: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String?
    var firstName: String?
    var lastName: String?
    var role: String?
    var status: StaffStatus?
    var email: String?
    var birthDate: Timestamp?
    var profileImageURL: String?
    var workSchedule: WorkSchedule?
    var inviteCode: String?

    var name: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmed
    }

    var initials: String { name.initials }

    var currentStatus: StaffStatus { status ?? .available }

    var schedule: WorkSchedule { workSchedule ?? WorkSchedule() }
}
