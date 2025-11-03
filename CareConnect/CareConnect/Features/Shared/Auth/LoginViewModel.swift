//
//  LoginViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

@MainActor
final class LoginViewModel: ObservableObject {
    /// Benutzer-E-Mail
    @Published var email = ""
    /// Passwort
    @Published var password = ""
    /// Fehlermeldung
    @Published var errorMessage: String?
    /// Ladezustand
    @Published var isLoading = false

    let appState: AppStateViewModel
    init(appState: AppStateViewModel) { self.appState = appState }

    /// Anmeldung durchführen
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user

            // Optional: sofort Rolle prüfen (AppState lädt sie ebenfalls noch mal)
            let db = Firestore.firestore()
            let isEmp = try await db.collection("employees").document(user.uid).getDocument().exists
            let isPat = try await db.collection("patients").document(user.uid).getDocument().exists
            print(isEmp ? "✅ Mitarbeiter" : (isPat ? "✅ Patient" : "⚠️ Rolle unbekannt"))

            await MainActor.run { appState.setLoggedIn(user: user) }
        } catch {
            errorMessage = "Fehler beim Login: \(error.localizedDescription)"
        }
    }
}
