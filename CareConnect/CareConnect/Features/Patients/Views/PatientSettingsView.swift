//
//  PatientSettingsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 24.10.25.
//

import SwiftUI
import FirebaseAuth

struct PatientSettingsView: View {
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// Profil bearbeiten
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
                                .font(.caption)
                                .foregroundColor(.secondary)
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
            .navigationTitle("Patienten-Einstellungen")
            .sheet(isPresented: $showEditProfile, onDismiss: {
                Task { await appState.loadInitial() }
            }) {
                if let patient = appState.currentPatient {
                    EditPatientProfileView(patient: Binding(
                        get: { appState.currentPatient ?? patient },
                        set: { appState.currentPatient = $0 }
                    ))
                } else {
                    VStack(spacing: 12) {
                        Text("Keine Patientendaten geladen.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
    }

    /// Anzeigename
    private var displayName: String {
        if let p = appState.currentPatient {
            return "\(p.firstName) \(p.lastName)"
        }
        return "Unbekannt"
    }

    /// Initialen
    private var initials: String {
        if let p = appState.currentPatient {
            let firstInitial = p.firstName?.first.map { String($0) } ?? "?"
            let lastInitial = p.lastName?.first.map { String($0) } ?? "?"
            return firstInitial + lastInitial
        }
        return "?"
    }
}

#Preview {
    PatientSettingsView()
        .environmentObject(AppStateViewModel())
}
