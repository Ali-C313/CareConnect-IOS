//
//  AppearanceSection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Dunkelmodus und Sprache
struct AppearanceSection: View {
    @Environment(AppStateViewModel.self) private var appState

    var body: some View {
        // Bindings für Toggle, Picker und Alert
        @Bindable var appState = appState

        Section(tr("Darstellung")) {
            Toggle(isOn: $appState.isDarkMode) {
                Label(tr("Dunkelmodus"), systemImage: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            .tint(CCDesign.accent)

            Picker(selection: $appState.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.nativeName).tag(language)
                }
            } label: {
                Label(tr("Sprache"), systemImage: "globe")
            }
        }
    }
}
