//
//  PatientSettingsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Einstellungen für Patienten
struct PatientSettingsView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var showLogoutDialog = false

    private var patient: Patient? { appState.currentPatient }

    var body: some View {
        Form {
            ProfileSection(
                name: patient?.name ?? tr("Unbekannt"),
                email: (patient?.email ?? appState.profile?.email ?? "").ifBlank("—"),
                imageURL: patient?.profileImageURL
            ) {
                EditPatientProfileView()
            }

            OrganizationSection()
            SharingSection()
            PrivacySection(isEmployee: false)
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
    NavigationStack { PatientSettingsView() }
        .environment(AppStateViewModel())
}
