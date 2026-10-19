//
//  AppError.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Eigene Fehler mit Text in der gewählten Sprache
enum AppError: LocalizedError {
    case notLoggedIn
    case missingId
    case noOrganization
    case invalidInput(String)

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return tr("Kein eingeloggter Benutzer gefunden.")
        case .missingId: return tr("Die ID fehlt.")
        case .noOrganization: return tr("Keine Organisation ausgewählt.")
        case .invalidInput(let message): return message
        }
    }
}
