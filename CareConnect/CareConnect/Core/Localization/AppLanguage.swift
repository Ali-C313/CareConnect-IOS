//
//  AppLanguage.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Sprachen, die man in den Einstellungen wählen kann
enum AppLanguage: String, CaseIterable, Identifiable {
    case german = "de"
    case english = "en"
    case turkish = "tr"
    case arabic = "ar"
    case spanish = "es"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .german: return "Deutsch"
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .arabic: return "العربية"
        case .spanish: return "Español"
        }
    }

    /// Arabisch wird von rechts nach links angezeigt
    var isRightToLeft: Bool { self == .arabic }

    /// Unbekannte Sprache → Deutsch
    static func from(code: String?) -> AppLanguage {
        AppLanguage(rawValue: String((code ?? "").lowercased().prefix(2))) ?? .german
    }

    /// Sprache vom iPhone
    static var device: AppLanguage { from(code: Locale.preferredLanguages.first) }

    /// Aktuell gewählte Sprache, wird vom AppStateViewModel gesetzt
    static var current: AppLanguage = .device
}

/// Übersetzt einen deutschen Text in die gewählte Sprache.
/// Platzhalter {0}, {1}, … werden durch args ersetzt.
func tr(_ text: String, _ args: Any?...) -> String {
    let key = text.trimmed
    let table: [String: String]?
    switch AppLanguage.current {
    case .german: table = nil
    case .english: table = englishTable
    case .turkish: table = turkishTable
    case .arabic: table = arabicTable
    case .spanish: table = spanishTable
    }
    var result = table?[key] ?? key
    for (index, arg) in args.enumerated() {
        result = result.replacingOccurrences(of: "{\(index)}", with: arg.map { "\($0)" } ?? "")
    }
    // Leerzeichen am Anfang und Ende bleiben erhalten
    let start = String(text.prefix { $0 == " " })
    let end = String(text.reversed().prefix { $0 == " " })
    return key.isEmpty ? text : start + result + end
}
