//
//  UserRole.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Welche App angezeigt wird
enum UserRole: String, CaseIterable, Identifiable {
    case employee = "Mitarbeiter"
    case patient = "Patient"

    var id: String { rawValue }
}
