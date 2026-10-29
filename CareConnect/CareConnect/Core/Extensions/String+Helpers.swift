//
//  String+Helpers.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Kleine Hilfen für Texte
extension String {
    /// "Ali Chehab" → "AC"
    var initials: String {
        let letters = split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
            .uppercased()
        return letters.isEmpty ? "?" : letters
    }

    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Leer → Ersatztext
    func ifBlank(_ fallback: String) -> String { isBlank ? fallback : self }

    var isValidEmail: Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    /// Nur Ziffern und + für tel:-Links
    var phoneDigits: String { filter { $0.isNumber || $0 == "+" } }
}
