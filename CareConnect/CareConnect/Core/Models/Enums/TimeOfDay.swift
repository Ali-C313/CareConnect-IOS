//
//  TimeOfDay.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Einnahmezeit, der deutsche Text steht so in Firestore
enum TimeOfDay: String, Codable, CaseIterable, Identifiable {
    case morning = "Morgens"
    case noon = "Mittags"
    case evening = "Abends"

    var id: String { rawValue }

    var displayName: String { tr(rawValue) }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = TimeOfDay(rawValue: value) ?? .morning
    }
}
