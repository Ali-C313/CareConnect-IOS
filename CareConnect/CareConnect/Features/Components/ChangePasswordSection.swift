//
//  ChangePasswordSection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Formular-Section zum Passwort ändern
struct ChangePasswordSection: View {
    @State private var viewModel = ChangePasswordViewModel()

    var body: some View {
        Section(tr("Passwort ändern")) {
            SecureField(tr("Aktuelles Passwort"), text: $viewModel.currentPassword)
                .textContentType(.password)
            SecureField(tr("Neues Passwort"), text: $viewModel.newPassword)
                .textContentType(.newPassword)
            SecureField(tr("Neues Passwort bestätigen"), text: $viewModel.confirmPassword)
                .textContentType(.newPassword)

            Button {
                Task { await viewModel.changePassword() }
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Label(tr("Passwort ändern"), systemImage: "key.fill")
                }
            }
            .disabled(!viewModel.canSubmit)
        }
        .messageAlert(tr("Passwort"), message: $viewModel.message)
    }
}

#Preview {
    Form { ChangePasswordSection() }
}
