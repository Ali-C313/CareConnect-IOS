//
//  Timestamp.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import Foundation
import FirebaseFirestore

// MARK: - Display helpers for Firestore Timestamp
extension Timestamp {
    /// The `Date` representation of this Firestore timestamp.
    var date: Date { self.dateValue() }

    /// Formats the timestamp using a shared DateFormatter (default: "dd.MM.yyyy", de_DE).
    var formattedDate: String {
        Self.displayDateFormatter.string(from: date)
    }

    /// Formats the timestamp with a custom format string, e.g. "dd.MM.yyyy, HH:mm"
    func formatted(_ format: String) -> String {
        Self.makeFormatter(format: format).string(from: date)
    }

    /// Age in full years computed from this birth date to today.
    var ageYears: Int? {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }

    // MARK: - Private formatters
    private static let displayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()

    private static func makeFormatter(format: String) -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = format
        return df
    }
}
