//
//  StaffStatus.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Mitarbeiterstatus, der deutsche Text steht so in Firestore
enum StaffStatus: String, Codable, CaseIterable, Identifiable {
    case available = "Verfügbar"
    case busy = "Beschäftigt"
    case pause = "Pause"
    case off = "Frei"
    case vacation = "Urlaub"

    var id: String { rawValue }

    var displayName: String { tr(rawValue) }

    var color: Color {
        switch self {
        case .available: return .green
        case .busy: return .orange
        case .pause: return .yellow
        case .off: return .red
        case .vacation: return .blue
        }
    }

    var icon: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .busy: return "bolt.circle.fill"
        case .pause: return "pause.circle.fill"
        case .off: return "xmark.circle.fill"
        case .vacation: return "airplane.circle.fill"
        }
    }

    /// Nur wer gerade arbeitet, bekommt Benachrichtigungen
    var isWorking: Bool { self == .available || self == .busy }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = StaffStatus(rawValue: value) ?? .available
    }
}
