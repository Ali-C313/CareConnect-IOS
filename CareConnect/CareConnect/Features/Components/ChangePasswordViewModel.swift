//
//  ChangePasswordViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Logik zum Passwort ändern
@MainActor
@Observable
final class ChangePasswordViewModel {
    var currentPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    var message: String?
    private(set) var isSaving = false

    private let auth: AuthRepository

    init(auth: AuthRepository? = nil) {
        self.auth = auth ?? AppContainer.shared.auth
    }

    var canSubmit: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && !isSaving
    }

    func changePassword() async {
        guard newPassword.count >= 6 else {
            message = tr("Das neue Passwort muss mindestens 6 Zeichen haben.")
            return
        }
        guard newPassword == confirmPassword else {
            message = tr("Die neuen Passwörter stimmen nicht überein.")
            return
        }
        isSaving = true
        defer { isSaving = false }

        do {
            try await auth.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            message = tr("Passwort erfolgreich geändert.")
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch {
            message = tr("Fehler: {0}", error.localizedDescription)
        }
    }
}
