//
//  EmployeeSettingsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth

struct EmployeeSettingsView: View {
    @EnvironmentObject var appState: AppStateViewModel
    /// Profil bearbeiten anzeigen
    @State private var showEditProfile = false

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    HStack(spacing: 12) {
                        AvatarView(initials: initials, size: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName).font(.headline)
                            Text(appState.currentUser?.email ?? "—")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button { showEditProfile = true } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }

                Section("Darstellung") {
                    Toggle(isOn: $appState.isDarkMode) {
                        Label("Dunkelmodus",
                              systemImage: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(.accentColor)
                }

                Section {
                    Button(role: .destructive) { appState.logout() } label: {
                        Label("Abmelden", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .sheet(isPresented: $showEditProfile, onDismiss: {
                Task { await appState.loadInitial() }
            }) {
                if let emp = appState.currentEmployee {
                    EditProfileView(employee: emp)
                } else {
                    Text("Kein Mitarbeiterprofil gefunden.").padding()
                }
            }
        }
    }

    /// Anzeigename
    private var displayName: String {
        if let e = appState.currentEmployee { return "\(e.firstName) \(e.lastName)" }
        return "Unbekannt"
    }
    /// Initialen
    private var initials: String {
        if let e = appState.currentEmployee {
            return "\(e.firstName.first ?? "?")\(e.lastName.first ?? "?")"
        }
        return "?"
    }
}

#Preview {
    EmployeeSettingsView()
        .environmentObject(AppStateViewModel())
}
