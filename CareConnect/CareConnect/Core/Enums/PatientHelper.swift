//
//  PatientHelper.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import Foundation

// MARK: - Helper functions for patient-related logic
struct PatientHelper {

    /// Returns up to two initials from a full name (e.g. "Ali Chehab" → "AC").
    static func initials(from name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "--" }
        return name.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
            .uppercased()
    }

    /// Validates whether a string is a correctly formatted email address.
    static func isValidEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let regex = /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/
        return email.range(of: regex) != nil
    }

    /// Formats a phone number by removing spaces and invalid characters.
    static func formattedPhone(_ number: String?) -> String {
        guard let number = number else { return "" }
        return number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
