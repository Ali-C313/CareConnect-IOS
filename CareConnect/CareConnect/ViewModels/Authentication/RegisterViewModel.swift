//
//  RegisterViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    let appState: AppStateViewModel
    init(appState: AppStateViewModel) { self.appState = appState }

    func createAccount() async -> User? {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte E-Mail und Passwort eingeben."
            return nil
        }
        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            return nil
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user
        } catch {
            errorMessage = "Fehler bei der Registrierung: \(error.localizedDescription)"
            return nil
        }
    }
}
