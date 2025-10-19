//
//  Status.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation
import SwiftUI

/// Verfügbare Mitarbeiterstatus
enum StaffStatus: String, CaseIterable, Identifiable, Codable {
    case available = "Verfügbar"
    case busy = "Beschäftigt"
    case offline = "Offline"
    
    var id: String { self.rawValue }
    
    /// Icon pro Status
    var icon: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .busy: return "clock.fill"
        case .offline: return "xmark.circle.fill"
        }
    }
    
    /// Farbe pro Status
    var color: Color {
        switch self {
        case .available: return .green
        case .busy: return .orange
        case .offline: return .red
        }
    }
}
