//
//  PrivacySection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Benachrichtigungen und Standort-Freigabe
struct PrivacySection: View {
    @Environment(AppStateViewModel.self) private var appState
    let isEmployee: Bool

    var body: some View {
        // Bindings für Toggle, Picker und Alert
        @Bindable var appState = appState

        Section(tr("Benachrichtigungen & Standort")) {
            Toggle(isOn: $appState.notificationsEnabled) {
                rowLabel(
                    title: tr("Benachrichtigungen"),
                    subtitle: isEmployee
                        ? tr("Neue Aufträge und Verordnungen, nur wenn du Verfügbar oder Beschäftigt bist")
                        : tr("Wenn sich an deinen Aufträgen etwas ändert"),
                    icon: "bell.fill"
                )
            }

            if isEmployee {
                Toggle(isOn: Binding(get: { appState.shareLocation == true }, set: { appState.shareLocation = $0 })) {
                    rowLabel(title: tr("Standort bei Einsätzen teilen"),
                             subtitle: tr("Der Patient sieht, wann du ankommst"),
                             icon: "location.fill")
                }
            } else {
                Toggle(isOn: Binding(get: { appState.showLiveLocation == true }, set: { appState.showLiveLocation = $0 })) {
                    rowLabel(title: tr("Live-Standort anzeigen"),
                             subtitle: tr("Mitarbeiter auf der Karte sehen, wenn er unterwegs ist"),
                             icon: "location.fill")
                }
            }
        }
        .tint(CCDesign.accent)
    }

    private func rowLabel(title: String, subtitle: String, icon: String) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: icon)
        }
    }
}
