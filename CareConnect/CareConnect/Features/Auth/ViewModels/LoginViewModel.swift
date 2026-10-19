//
//  LoginViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var errorMessage: String?
    private(set) var isLoading = false

    private let auth: AuthRepository

    init(auth: AuthRepository? = nil) {
        self.auth = auth ?? AppContainer.shared.auth
    }

    var isFormValid: Bool {
        !email.isBlank && !password.isEmpty
    }

    /// Nach dem Login wechselt das AppStateViewModel automatisch den Screen
    func login() async {
        guard isFormValid else {
            errorMessage = tr("Bitte E-Mail und Passwort eingeben.")
            return
        }
        isLoading = true
        defer { isLoading = false }

        do {
            errorMessage = nil
            try await auth.signIn(email: email, password: password)
        } catch {
            errorMessage = tr("Fehler beim Login: {0}", error.localizedDescription)
        }
    }
}
