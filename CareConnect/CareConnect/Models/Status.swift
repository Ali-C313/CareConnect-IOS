//
//  Status.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import SwiftUI

enum StaffStatus: String, CaseIterable, Identifiable, Codable {
    case available = "Verfügbar"
    case busy      = "Beschäftigt"
    case pause     = "Pause"
    case off       = "Frei"
    case vacation  = "Urlaub"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .available: return .green
        case .busy:      return .orange
        case .pause:     return .yellow
        case .off:       return .red
        case .vacation:  return .blue
        }
    }

    var icon: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .busy:      return "bolt.circle.fill"
        case .pause:     return "pause.circle.fill"
        case .off:       return "xmark.circle.fill"
        case .vacation:  return "airplane.circle.fill"
        }
    }
}
