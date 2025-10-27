//
//  LoginView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var viewModel: LoginViewModel
    @State private var navigateToRegister = false
    
    init(appState: AppStateViewModel) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }
    
    private var isFormValid: Bool {
        !viewModel.email.isEmpty && !viewModel.password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Anmelden")
                        .font(.largeTitle.bold())
                        .foregroundColor(CCDesign.textPrimary)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        TextField("E-Mail-Adresse", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding()
                            .background(CCDesign.card)
                            .cornerRadius(10)
                        
                        SecureField("Passwort", text: $viewModel.password)
                            .padding()
                            .background(CCDesign.card)
                            .cornerRadius(10)
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
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Einloggen")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.accentColor : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
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
                            .foregroundColor(.accentColor)
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
