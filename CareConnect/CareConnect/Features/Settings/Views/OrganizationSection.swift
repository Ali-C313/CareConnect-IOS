//
//  OrganizationSection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Aktuelle Organisation, Wechsel, Verwalten (nur Leitung) und Austreten
struct OrganizationSection: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var showAddSheet = false
    @State private var showLeaveDialog = false

    private var others: [Membership] {
        appState.memberships.filter { $0.orgId != appState.orgId }
    }

    var body: some View {
        Section(tr("Organisation")) {
            if let current = appState.membership {
                VStack(alignment: .leading, spacing: 2) {
                    Text(current.orgName).font(.headline)
                    Text("\(current.orgType.displayName) · \(current.role.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ForEach(others) { membership in
                Button {
                    appState.switchOrganization(to: membership.orgId ?? "")
                } label: {
                    Label(tr("Wechseln zu") + " \(membership.orgName) (\(membership.role.displayName))",
                          systemImage: "arrow.left.arrow.right")
                }
            }

            if appState.membership?.role == .admin {
                NavigationLink {
                    ManageOrganizationView()
                } label: {
                    Label(tr("Organisation verwalten"), systemImage: "person.2.badge.gearshape")
                }
            }

            Button {
                showAddSheet = true
            } label: {
                Label(tr("Weitere Organisation hinzufügen"), systemImage: "plus")
            }

            if let current = appState.membership, current.role != .admin {
                Button(role: .destructive) {
                    showLeaveDialog = true
                } label: {
                    Label(tr("Organisation verlassen"), systemImage: "rectangle.portrait.and.arrow.forward")
                }
            }
        }
        .alert(tr("{0} verlassen?", appState.membership?.orgName ?? ""), isPresented: $showLeaveDialog) {
            Button(tr("Verlassen"), role: .destructive) { appState.leaveOrganization() }
            Button(tr("Abbrechen"), role: .cancel) {}
        } message: {
            Text(tr("Du hast danach keinen Zugriff mehr auf die Daten dieser Organisation."))
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form { OrganizationSetupView() }
                    .navigationTitle(tr("Organisation"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(tr("Abbrechen")) { showAddSheet = false }
                        }
                    }
            }
        }
    }
}
