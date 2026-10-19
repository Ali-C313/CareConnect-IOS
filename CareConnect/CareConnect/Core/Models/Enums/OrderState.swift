//
//  OrderState.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Auftragsstatus, in Firestore klein geschrieben
enum OrderState: String, Codable, CaseIterable, Identifiable {
    case offen
    case aktuell
    case erledigt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .offen: return tr("Offen")
        case .aktuell: return tr("Aktuell")
        case .erledigt: return tr("Erledigt")
        }
    }

    /// Text aus Sicht des Patienten ("Unterwegs" statt "Aktuell")
    var patientLabel: String {
        self == .aktuell ? tr("Unterwegs") : displayName
    }

    var color: Color {
        switch self {
        case .offen: return .orange
        case .aktuell: return .blue
        case .erledigt: return .green
        }
    }

    var icon: String {
        switch self {
        case .offen: return "clock"
        case .aktuell: return "play.circle.fill"
        case .erledigt: return "checkmark.circle.fill"
        }
    }

    // Unbekannte Werte werden zu "offen"
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = OrderState(rawValue: value.lowercased()) ?? .offen
    }
}
