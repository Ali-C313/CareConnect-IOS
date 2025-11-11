//
//  OrderState.swift
//  CareConnect
//
//  Created by Ali Chehab on 10.11.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

/// Auftragsstatus
enum OrderState: String, Codable, CaseIterable, Identifiable {
    case aktuell  = "aktuell"
    case offen    = "offen"
    case erledigt = "erledigt"

    var id: String { rawValue }
    var displayName: String { rawValue }
    var color: Color {
        switch self {
        case .offen:    return .orange
        case .aktuell:  return .blue
        case .erledigt: return .green
        }
    }
}
