//
//  CareConnectApp.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Firebase

@main
struct CareConnectApp: App {
    /// App-Status
    @StateObject private var appState = AppStateViewModel()

    /// Firebase konfigurieren
    init() {
        FirebaseApp.configure()
    }

    /// Start-View
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}
