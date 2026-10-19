//
//  OnboardingView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Nach der Registrierung: noch keiner Organisation zugeordnet
struct OnboardingView: View {
    @Environment(AppStateViewModel.self) private var appState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(tr("Du bist noch keiner Organisation zugeordnet. Tritt mit einem Code bei oder gründe deine eigene."))
                        .foregroundColor(.secondary)
                }

                OrganizationSetupView()

                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Label(tr("Abmelden"), systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle(tr("Willkommen"))
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppStateViewModel())
}
