//
//  EditEmployeeProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Name, Rolle, E-Mail, Profilbild und Passwort ändern
struct EditEmployeeProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = EditEmployeeProfileViewModel()

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
                TextField(tr("Rolle"), text: $viewModel.role)
                TextField(tr("E-Mail"), text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
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
        .onAppear { viewModel.load(from: appState.currentEmployee) }
        .messageAlert(tr("Hinweis"), message: $viewModel.message)
    }
}

#Preview {
    NavigationStack { EditEmployeeProfileView() }
        .environment(AppStateViewModel())
}
