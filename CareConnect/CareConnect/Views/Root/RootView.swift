//
//  RootView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var appState: AppStateViewModel

    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.role == "Patient" {
                    PatientTabView()
                } else {
                    MainTabView() // bestehende Mitarbeiter-Tabs bleiben
                }
            } else {
                LoginView(appState: appState)
            }
        }
        .animation(.easeInOut, value: appState.isLoggedIn)
    }
}
