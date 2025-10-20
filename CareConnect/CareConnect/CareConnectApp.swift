//
//  CareConnectApp.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct CareConnectApp: App {
    
    // AppStateViewModel steuert globale wie Login, Sprache etc.
    @StateObject private var appState = AppStateViewModel()
    
    // Dark Mode Einstellung aus den AppStorage lesen/speichern
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    init() {
        // Firebase initialisieren
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Reaktiver Wechsel zwischen Light/Dark Mode
                .preferredColorScheme(isDarkMode ? .dark : .light)
                // Sprache dynamisch über Environment übergeben
                .environment(\.locale, appState.appLocale)
                // AppState global bereitstellen
                .environmentObject(appState)
        }
    }
}
