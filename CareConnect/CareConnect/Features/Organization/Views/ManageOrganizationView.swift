//
//  ManageOrganizationView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Organisation verwalten (nur Leitung)
struct ManageOrganizationView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = ManageOrganizationViewModel()
    @State private var memberToRemove: Member?

    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(get: { viewModel.isListed }, set: { viewModel.setListed($0) })) {
                    Text(tr("In der Suche anzeigen"))
                }
                .tint(CCDesign.accent)
            } header: {
                Text(tr("Sichtbarkeit"))
            } footer: {
                Text(tr("Patienten können euch finden und anfragen."))
            }

            Section(tr("Beitrittsanfragen ({0})", viewModel.joinRequests.count)) {
                if viewModel.joinRequests.isEmpty {
                    Text(tr("Keine offenen Anfragen.")).foregroundColor(.secondary)
                }
                ForEach(viewModel.joinRequests) { request in
                    RequestRow(request: request) {
                        viewModel.accept(request)
                    } onDecline: {
                        viewModel.decline(request)
                    }
                }
            }

            invitesSection

            Section(tr("Mitglieder ({0})", viewModel.members.count)) {
                ForEach(viewModel.members) { member in
                    MemberRow(member: member, isSelf: member.id == appState.userId) { role in
                        viewModel.changeRole(of: member, to: role)
                    } onRemove: {
                        memberToRemove = member
                    }
                }
            }
        }
        .navigationTitle(viewModel.organization?.name ?? tr("Organisation"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            tr("{0} entfernen?", memberToRemove?.name ?? ""),
            isPresented: Binding(get: { memberToRemove != nil }, set: { if !$0 { memberToRemove = nil } })
        ) {
            Button(tr("Entfernen"), role: .destructive) {
                if let memberToRemove { viewModel.remove(memberToRemove) }
            }
            Button(tr("Abbrechen"), role: .cancel) {}
        } message: {
            Text(tr("Die Person hat danach keinen Zugriff mehr auf eure Daten. Ihre bisherigen Einträge bleiben erhalten."))
        }
        .messageAlert(tr("Organisation"), message: $viewModel.message)
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
    }

    private var invitesSection: some View {
        Section {
            ForEach(viewModel.invites) { invite in
                HStack {
                    VStack(alignment: .leading) {
                        Text(invite.id)
                            .font(.headline.monospaced())
                            .textSelection(.enabled)
                        Text(tr("für {0}", invite.role.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        viewModel.deleteInvite(invite)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(tr("Code löschen"))
                }
            }
            HStack {
                Button(tr("+ Mitarbeiter")) { viewModel.createInvite(role: .staff) }
                Spacer()
                Button(tr("+ Patient")) { viewModel.createInvite(role: .patient) }
            }
            .buttonStyle(.borderless)
        } header: {
            Text(tr("Einladungscodes"))
        } footer: {
            Text(tr("Gib die Codes an dein Team oder deine Patienten weiter. Lange drücken zum Kopieren."))
        }
    }
}

/// Mitglied mit Menü zum Ändern der Rolle
struct MemberRow: View {
    let member: Member
    let isSelf: Bool
    let onRoleChange: (MemberRole) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(isSelf ? tr("{0} (du)", member.name) : member.name).fontWeight(.semibold)
                Text(member.role.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // Sich selbst kann man nicht ändern, damit immer eine Leitung bleibt
            if !isSelf {
                Menu {
                    if member.role == .staff {
                        Button(tr("Zur Leitung machen")) { onRoleChange(.admin) }
                    } else if member.role == .admin {
                        Button(tr("Zum Mitarbeiter machen")) { onRoleChange(.staff) }
                    }
                    Button(tr("Entfernen"), role: .destructive, action: onRemove)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(tr("Optionen"))
            }
        }
    }
}

/// Beitrittsanfrage mit Annehmen / Ablehnen
struct RequestRow: View {
    let request: JoinRequest
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(request.name).fontWeight(.semibold)
            let place = [request.address, request.city].filter { !$0.isBlank }.joined(separator: ", ")
            ForEach([place, request.email].filter { !$0.isBlank }, id: \.self) { line in
                Text(line)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack {
                Button(tr("Annehmen"), action: onAccept)
                    .buttonStyle(.borderedProminent)
                Button(tr("Ablehnen"), action: onDecline)
                    .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    NavigationStack { ManageOrganizationView() }
        .environment(AppStateViewModel())
}
