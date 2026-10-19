//
//  PrescriptionStatus.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Status einer Verordnung
enum PrescriptionStatus: String, Codable, CaseIterable, Identifiable {
    case offen
    case angenommen
    case abgelehnt
    case erledigt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .offen: return tr("Offen")
        case .angenommen: return tr("Übernommen")
        case .abgelehnt: return tr("Abgelehnt")
        case .erledigt: return tr("Erledigt")
        }
    }

    var color: Color {
        switch self {
        case .offen: return .orange
        case .angenommen: return .blue
        case .abgelehnt: return .red
        case .erledigt: return .green
        }
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = PrescriptionStatus(rawValue: value) ?? .offen
    }
}
