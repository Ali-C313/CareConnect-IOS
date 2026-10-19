//
//  SharingSection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Freigaben für Verordnungen von Praxis an Pflegedienst
struct SharingSection: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = SharingViewModel()

    var body: some View {
        Section {
            if viewModel.entries.isEmpty {
                Text(tr("Bist du bei einer Praxis und bei einem Pflegedienst, kannst du hier erlauben, ") +
                     tr("dass die Praxis Verordnungen direkt an deinen Pflegedienst schickt."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.entries) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tr("{0} darf schicken an:", entry.source.orgName)).fontWeight(.semibold)
                        ForEach(viewModel.careServices) { careService in
                            Toggle(careService.orgName, isOn: Binding(
                                get: { entry.linkedOrgIds.contains(careService.orgId ?? "") },
                                set: { _ in viewModel.toggle(entry, careService: careService) }
                            ))
                        }
                    }
                }
            }
        } header: {
            Text(tr("Freigaben"))
        } footer: {
            if !viewModel.entries.isEmpty {
                Text(tr("Nur Verordnungen, keine anderen Daten. Du kannst das jederzeit wieder ausschalten."))
            }
        }
        .tint(CCDesign.accent)
        .onAppear { viewModel.update(memberships: appState.memberships) }
        .onChange(of: appState.memberships) { _, newValue in viewModel.update(memberships: newValue) }
        .onDisappear { viewModel.stopListening() }
        .messageAlert(tr("Freigaben"), message: $viewModel.message)
    }
}
