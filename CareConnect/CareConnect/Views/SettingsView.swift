//
//  SettingsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    
    @EnvironmentObject var appState: AppStateViewModel
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profil")) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(appState.currentUserName)
                                .font(.headline)
                            Text("Angemeldet")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Darstellung")) {
                    Toggle("Dunkelmodus", isOn: $isDarkMode)
                }
                
                Section(header: Text("Sprache")) {
                    Picker("App-Sprache", selection: $appState.appLocale) {
                        Text("Deutsch").tag(Locale(identifier: "de"))
                        Text("English").tag(Locale(identifier: "en"))
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Label("Abmelden", systemImage: "arrow.right.square.fill")
                    }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}

#Preview { SettingsView().environmentObject(AppStateViewModel()) }
