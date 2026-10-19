//
//  RegisterView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

struct RegisterView: View {
    @State private var viewModel = RegisterViewModel()

    var body: some View {
        Form {
            Section {
                ImagePicker(selectedImage: $viewModel.image)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }

            Section(tr("Persönliche Daten")) {
                TextField(tr("Vorname"), text: $viewModel.firstName)
                    .textContentType(.givenName)
                TextField(tr("Nachname"), text: $viewModel.lastName)
                    .textContentType(.familyName)
                DatePicker(tr("Geburtsdatum"), selection: $viewModel.birthDate, displayedComponents: .date)
            }

            // Adresse brauchen vor allem Patienten (Hausbesuche, Karte)
            Section(tr("Adresse & Kontakt")) {
                AddressSearchField(address: $viewModel.address)
                TextField(tr("Stadt"), text: $viewModel.city)
                TextField(tr("Telefonnummer"), text: $viewModel.phone)
                    .keyboardType(.phonePad)
            }

            Section(tr("Zugangsdaten")) {
                TextField(tr("E-Mail-Adresse"), text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField(tr("Passwort"), text: $viewModel.password)
                    .textContentType(.newPassword)
                SecureField(tr("Passwort bestätigen"), text: $viewModel.confirmPassword)
                    .textContentType(.newPassword)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundColor(.red)
                }
            }

            Section {
                Button {
                    Task { await viewModel.register() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text(tr("Konto erstellen"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle(tr("Registrieren"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { RegisterView() }
}
