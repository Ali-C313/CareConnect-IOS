//
//  AuthViews.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth

/// Diese View verwaltet die Anmeldung und Registrierung.
/// Sie nutzt Firebase Authentication (E-Mail & Passwort).
struct AuthView: View {
    @EnvironmentObject var appState: AppStateViewModel
    
    // Eingabefelder
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Modus (Login oder Registrierung)
    @State private var isLoginMode: Bool = true
    
    // Fehleranzeige
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Titel
                Text(isLoginMode ? "Anmelden" : "Registrieren")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)
                
                // Textfelder
                VStack(spacing: 16) {
                    TextField("E-Mail-Adresse", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    SecureField("Passwort", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    if !isLoginMode {
                        SecureField("Passwort bestätigen", text: $confirmPassword)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Fehlermeldung anzeigen, falls vorhanden
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Login- oder Registrieren-Button
                Button {
                    Task { await handleAuthAction() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLoginMode ? "Einloggen" : "Konto erstellen")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .disabled(isLoading)
                
                // Modus wechseln
                Button {
                    withAnimation { isLoginMode.toggle() }
                    errorMessage = nil
                } label: {
                    Text(isLoginMode ? "Noch kein Konto? Jetzt registrieren" :
                         "Bereits registriert? Jetzt anmelden")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            .navigationTitle("CareConnect Login")
        }
    }
    
    // MARK: - Firebase Login / Registrierung
    
    /// Führt Login oder Registrierung über FirebaseAuth aus.
    private func handleAuthAction() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isLoginMode {
                // Benutzer einloggen
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                print("✅ Eingeloggt als \(result.user.email ?? "")")
                await MainActor.run {
                    appState.isLoggedIn = true
                    appState.currentUserName = result.user.email ?? "Benutzer"
                }
            } else {
                // Registrierung
                guard password == confirmPassword else {
                    errorMessage = "Passwörter stimmen nicht überein."
                    isLoading = false
                    return
                }
                
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                print("✅ Neues Konto erstellt: \(result.user.email ?? "")")
                await MainActor.run {
                    appState.isLoggedIn = true
                    appState.currentUserName = result.user.email ?? "Benutzer"
                }
            }
        } catch {
            errorMessage = "Fehler: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    AuthView()
}
