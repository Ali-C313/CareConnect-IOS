//
//  EmployeeSettingsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Einstellungen für Mitarbeiter
struct EmployeeSettingsView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var showLogoutDialog = false

    private var employee: Employee? { appState.currentEmployee }

    var body: some View {
        Form {
            ProfileSection(
                name: (employee?.name ?? "").ifBlank(tr("Unbekannt")),
                email: (employee?.email ?? appState.profile?.email ?? "").ifBlank("—"),
                imageURL: employee?.profileImageURL
            ) {
                EditEmployeeProfileView()
            }

            OrganizationSection()
            PrivacySection(isEmployee: true)
            AppearanceSection()

            Section {
                Button(role: .destructive) {
                    showLogoutDialog = true
                } label: {
                    Label(tr("Abmelden"), systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .screenBackground()
        .navigationTitle(tr("Einstellungen"))
        .alert(tr("Abmelden?"), isPresented: $showLogoutDialog) {
            Button(tr("Abmelden"), role: .destructive) { appState.logout() }
            Button(tr("Abbrechen"), role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack { EmployeeSettingsView() }
        .environment(AppStateViewModel())
}
