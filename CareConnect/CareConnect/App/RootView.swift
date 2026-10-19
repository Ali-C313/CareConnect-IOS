//
//  RootView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Login → Organisation wählen/gründen → Mitarbeiter- oder Patienten-App
struct RootView: View {
    @Environment(AppStateViewModel.self) private var appState

    var body: some View {
        // Bindings für Toggle, Picker und Alert
        @Bindable var appState = appState

        Group {
            switch appState.session {
            case .loading:
                ProgressView(tr("Profil wird geladen …"))
            case .loggedOut:
                LoginView()
            case .missingProfile:
                missingProfile
            case .needsOrganization:
                OnboardingView()
            case .loggedIn:
                if appState.role == .employee {
                    MainTabView()
                } else {
                    PatientTabView()
                }
            }
        }
        // Beim Wechsel der Organisation alles neu aufbauen
        .id(appState.orgId)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .animation(.easeInOut, value: appState.session)
        // Mitarbeiter bestätigt einmal, dass sein Standort während des Einsatzes geteilt wird
        .alert(tr("Standort teilen?"), isPresented: .constant(appState.needsLocationConsent)) {
            Button(tr("Teilen")) { appState.shareLocation = true }
            Button(tr("Nicht teilen"), role: .cancel) { appState.shareLocation = false }
        } message: {
            Text(tr("Du hast einen Auftrag angenommen. Der Patient kann dann auf der Karte sehen, wo du bist und wann du ungefähr ankommst. Geteilt wird nur, solange der Auftrag läuft. Du kannst das jederzeit in den Einstellungen ändern."))
        }
        .messageAlert(tr("Hinweis"), message: $appState.message)
    }

    /// Eingeloggt, aber das Profil wird gerade erst angelegt oder fehlt
    private var missingProfile: some View {
        ContentUnavailableView {
            Label(tr("Kein Profil gefunden"), systemImage: "person.crop.circle.badge.questionmark")
        } description: {
            Text(tr("Du bist angemeldet, aber es wurde noch kein Profil gefunden. Das Profil wird gerade geladen oder fehlt."))
        } actions: {
            Button(tr("Abmelden")) { appState.logout() }
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    RootView()
        .environment(AppStateViewModel())
}
