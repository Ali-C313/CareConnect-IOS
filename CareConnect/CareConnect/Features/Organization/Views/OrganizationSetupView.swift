//
//  OrganizationSetupView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Beitreten per Code, Organisation suchen oder eigene gründen.
/// Wird im Onboarding und in den Einstellungen benutzt (als Sections in einer Form).
struct OrganizationSetupView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = OrganizationViewModel()

    var body: some View {
        Group {
            Section {
                TextField(tr("Einladungscode"), text: $viewModel.code)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                Button {
                    viewModel.join(memberships: appState.memberships)
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label(tr("Beitreten"), systemImage: "key.fill")
                    }
                }
                .disabled(viewModel.isLoading)
            } header: {
                Text(tr("Mit Code beitreten"))
            } footer: {
                Text(tr("Den Code bekommst du von deinem Pflegedienst, deiner Praxis oder deiner Klinik."))
            }

            searchSection

            Section {
                TextField(tr("Name"), text: $viewModel.orgName)
                Picker(tr("Art"), selection: $viewModel.orgType) {
                    ForEach(OrganizationType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField(tr("Adresse (optional)"), text: $viewModel.orgAddress)
                Button {
                    viewModel.create()
                } label: {
                    Label(tr("Organisation gründen"), systemImage: "building.2.fill")
                }
                .disabled(viewModel.isLoading)
            } header: {
                Text(tr("Organisation gründen"))
            } footer: {
                Text(tr("Du leitest einen Pflegedienst, eine Praxis oder eine Klinik? Lege sie hier an und lade dann dein Team und deine Patienten ein."))
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundColor(.red)
                }
            }
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
        .onChange(of: viewModel.searchText) { viewModel.search() }
    }

    private var searchSection: some View {
        Section {
            TextField(tr("Name oder Ort"), text: $viewModel.searchText)
            if viewModel.isSearching {
                ProgressView()
            } else if viewModel.searchText.trimmed.count >= 2 && viewModel.searchResults.isEmpty {
                Text(tr("Nichts gefunden.")).foregroundColor(.secondary)
            }
            ForEach(viewModel.searchResults) { organization in
                HStack {
                    VStack(alignment: .leading) {
                        Text(organization.name).fontWeight(.semibold)
                        Text([organization.type.displayName, organization.address ?? ""]
                            .filter { !$0.isBlank }
                            .joined(separator: " · "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(tr("Anfragen")) {
                        viewModel.sendRequest(to: organization, memberships: appState.memberships)
                    }
                    .buttonStyle(.borderless)
                    .disabled(viewModel.isLoading)
                }
            }
            ForEach(viewModel.myRequests) { request in
                HStack {
                    VStack(alignment: .leading) {
                        Text(request.orgName).fontWeight(.semibold)
                        Text(request.status.displayName)
                            .font(.caption)
                            .foregroundColor(request.status == .declined ? .red : .secondary)
                    }
                    Spacer()
                    Button(request.status == .declined ? tr("Entfernen") : tr("Zurückziehen")) {
                        viewModel.cancelRequest(orgId: request.orgId)
                    }
                    .buttonStyle(.borderless)
                }
            }
        } header: {
            Text(tr("Organisation suchen"))
        } footer: {
            Text(tr("Kein Code? Such deinen Pflegedienst oder deine Praxis und frag als Patient an."))
        }
    }
}

#Preview {
    Form { OrganizationSetupView() }
        .environment(AppStateViewModel())
}
