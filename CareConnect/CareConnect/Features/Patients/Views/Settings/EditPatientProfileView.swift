//
//  EditPatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Kontaktdaten, medizinische Infos, Profilbild und Passwort ändern
struct EditPatientProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = EditPatientProfileViewModel()

    var body: some View {
        Form {
            Section {
                ImagePicker(selectedImage: $viewModel.selectedImage, currentImageURL: viewModel.profileImageURL)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section(tr("Allgemein")) {
                TextField(tr("Vorname"), text: $viewModel.firstName)
                    .textContentType(.givenName)
                TextField(tr("Nachname"), text: $viewModel.lastName)
                    .textContentType(.familyName)
                AddressSearchField(address: $viewModel.address)
                TextField(tr("Stadt"), text: $viewModel.city)
                    .textContentType(.addressCity)
                TextField(tr("E-Mail"), text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField(tr("Telefonnummer"), text: $viewModel.phone)
                    .keyboardType(.phonePad)
            }

            Section(tr("Medizinisch")) {
                TextField(tr("Allergien"), text: $viewModel.allergies, axis: .vertical)
                    .lineLimit(1...4)
                TextField(tr("Krankengeschichte"), text: $viewModel.medicalHistory, axis: .vertical)
                    .lineLimit(1...6)
            }

            ChangePasswordSection()
        }
        .navigationTitle(tr("Profil bearbeiten"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button(tr("Speichern")) {
                        Task {
                            if await viewModel.save() { dismiss() }
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.load(from: appState.currentPatient) }
        .messageAlert(tr("Hinweis"), message: $viewModel.message)
    }
}

#Preview {
    NavigationStack { EditPatientProfileView() }
        .environment(AppStateViewModel())
}
