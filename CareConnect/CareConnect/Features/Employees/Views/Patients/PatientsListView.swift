//
//  PatientsListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Alle Patienten der Organisation
struct PatientsListView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var searchText = ""

    private var filteredPatients: [Patient] {
        let sorted = appState.patients.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard !searchText.isBlank else { return sorted }
        return sorted.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.fullAddress.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if appState.patients.isEmpty {
                ContentUnavailableView(
                    tr("Keine Patienten gefunden"),
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text(tr("Neue Patienten erscheinen automatisch, sobald sie hinzugefügt werden."))
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPatients) { patient in
                            NavigationLink {
                                PatientProfileView(patientId: patient.id ?? "")
                            } label: {
                                PatientRow(patient: patient)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Patienten"))
        .searchable(text: $searchText, prompt: tr("Patient suchen"))
    }
}

#Preview {
    NavigationStack { PatientsListView() }
        .environment(AppStateViewModel())
}
