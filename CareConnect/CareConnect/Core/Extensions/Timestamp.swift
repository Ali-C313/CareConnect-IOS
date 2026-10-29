//
//  Timestamp.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Firestore-Datum als Text
extension Timestamp {
    var date: Date { dateValue() }

    /// z. B. 24.12.2025
    var formattedDate: String { date.formattedDate }

    /// z. B. 24.12.2025, 14:30
    var formattedDateTime: String { date.formattedDateTime }

    /// Alter in Jahren, wenn das ein Geburtsdatum ist
    var ageYears: Int {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
    }
}

/// Datum formatieren wie in der Android-App
extension Date {
    var timestamp: Timestamp { Timestamp(date: self) }

    /// z. B. 24.12.2025
    var formattedDate: String {
        formatted(.dateTime.day(.twoDigits).month(.twoDigits).year().locale(Locale(identifier: "de_DE")))
    }

    /// z. B. 14:30
    var formattedTime: String {
        formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).locale(Locale(identifier: "de_DE")))
    }

    /// z. B. 24.12.2025, 14:30
    var formattedDateTime: String { "\(formattedDate), \(formattedTime)" }

    /// Mittag, damit sich ein reines Datum durch Zeitzonen nicht verschiebt
    var atNoon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
}

/// Termine für wiederkehrende Aufträge
/// - Parameter weekdays: 1 = Montag bis 7 = Sonntag
/// - Returns: Zeitpunkte ab start (gleiche Uhrzeit) an den gewählten Wochentagen
func recurringDates(start: Date, weekdays: Set<Int>, weeks: Int) -> [Date] {
    let calendar = Calendar.current
    return (0..<(weeks * 7)).compactMap { offset in
        guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
        // Calendar zählt ab Sonntag = 1, umrechnen auf Montag = 1
        let weekday = (calendar.component(.weekday, from: date) + 5) % 7 + 1
        return weekdays.contains(weekday) ? date : nil
    }
}
