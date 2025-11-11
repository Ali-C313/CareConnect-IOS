//
//  LoginView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import Foundation

struct LoginView: View {
    
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// Login-ViewModel
    @StateObject private var viewModel: LoginViewModel
    /// Navigation zur Registrierung
    @State private var navigateToRegister = false
    
    init(appState: AppStateViewModel) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }
    
    /// Formularprüfung
    private var isFormValid: Bool {
        !viewModel.email.isEmpty && !viewModel.password.isEmpty
    }
    
    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Willkommen zurück")
                        .font(.largeTitle.bold())
                        .foregroundColor(CCDesign.textPrimary)
                        .padding(.top, 50)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("E-Mail", systemImage: "envelope.fill")
                                .foregroundColor(CCDesign.textSecondary)
                                .font(.caption)

                            TextField("E-Mail-Adresse", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Label("Passwort", systemImage: "lock.fill")
                                .foregroundColor(CCDesign.textSecondary)
                                .font(.caption)

                            SecureField("Passwort", text: $viewModel.password)
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button {
                        Task { await viewModel.login() }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Einloggen")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? CCDesign.accent : CCDesign.accent.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: CCDesign.accent.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid || viewModel.isLoading)
                    
                    .navigationDestination(isPresented: $navigateToRegister) {
                        RegisterView(appState: appState)
                    }
                    
                    Button {
                        navigateToRegister = true
                    } label: {
                        Text("Noch kein Konto? Jetzt registrieren")
                            .font(.footnote)
                            .foregroundColor(CCDesign.accent)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
            .navigationTitle("CareConnect")
        }
    }
}

#Preview {
    LoginView(appState: AppStateViewModel())
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
