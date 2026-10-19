//
//  CareConnectApp.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import FirebaseCore

@main
struct CareConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState: AppStateViewModel

    init() {
        // Muss vor allen Repos laufen
        FirebaseApp.configure()
        _appState = State(initialValue: AppStateViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
                // Arabisch von rechts nach links
                .environment(\.layoutDirection, appState.language.isRightToLeft ? .rightToLeft : .leftToRight)
                .environment(\.locale, Locale(identifier: appState.language.rawValue))
                // Beim Sprachwechsel alles neu zeichnen, damit tr() die neuen Texte liefert
                .id(appState.language)
                .tint(CCDesign.accent)
        }
    }
}
