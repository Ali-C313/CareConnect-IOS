//
//  MemberRole.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Rolle innerhalb einer Organisation
enum MemberRole: String, Codable, CaseIterable, Identifiable {
    case admin
    case staff
    case patient

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .admin: return tr("Leitung")
        case .staff: return tr("Mitarbeiter")
        case .patient: return tr("Patient")
        }
    }

    /// Leitung und Mitarbeiter sehen die Mitarbeiter-App
    var userRole: UserRole { self == .patient ? .patient : .employee }

    /// Reihenfolge in Listen
    var sortIndex: Int {
        switch self {
        case .admin: return 0
        case .staff: return 1
        case .patient: return 2
        }
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = MemberRole(rawValue: value) ?? .patient
    }
}
