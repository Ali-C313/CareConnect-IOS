//
//  LoginView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 64))
                            .foregroundColor(CCDesign.accent)
                        Text(tr("Willkommen"))
                            .font(.largeTitle.bold())
                            .foregroundColor(CCDesign.textPrimary)
                    }
                    .padding(.top, 50)

                    VStack(spacing: 18) {
                        inputField(label: tr("E-Mail"), icon: "envelope.fill") {
                            TextField(tr("E-Mail-Adresse"), text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        inputField(label: tr("Passwort"), icon: "lock.fill") {
                            SecureField(tr("Passwort"), text: $viewModel.password)
                                .textContentType(.password)
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
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(tr("Einloggen")).font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? CCDesign.accent : CCDesign.accent.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: CCDesign.accent.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)

                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text(tr("Noch kein Konto? Jetzt registrieren"))
                            .font(.footnote)
                            .foregroundColor(CCDesign.accent)
                    }
                    .padding(.bottom, 40)
                }
            }
            .screenBackground()
            .navigationTitle("CareConnect")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Feld mit kleiner Überschrift wie im Rest der App
    private func inputField<Field: View>(label: String, icon: String, @ViewBuilder field: () -> Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .foregroundColor(CCDesign.textSecondary)
                .font(.caption)
            field()
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
        }
    }
}

#Preview {
    LoginView()
}
