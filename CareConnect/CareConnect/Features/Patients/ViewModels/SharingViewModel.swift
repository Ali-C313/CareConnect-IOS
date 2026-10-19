//
//  SharingViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Eine Praxis/Klinik und die Pflegedienste, an die sie Verordnungen schicken darf
struct SharingEntry: Identifiable, Equatable {
    let source: Membership
    var linkedOrgIds: Set<String>

    var id: String { source.id }
}

/// Patient erlaubt einer Praxis, Verordnungen an seinen Pflegedienst zu schicken
@MainActor
@Observable
final class SharingViewModel {
    private(set) var entries: [SharingEntry] = []
    private(set) var careServices: [Membership] = []
    var message: String?

    private let container: AppContainer
    private var listeners: [ListenerHandle] = []
    private var loadedKey = ""

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Neu aufbauen, wenn sich die Mitgliedschaften ändern
    func update(memberships: [Membership]) {
        guard let uid = container.auth.currentUserId else { return }
        let ownMemberships = memberships.filter { $0.role == .patient }
        let key = ownMemberships.map(\.id).joined(separator: ",")
        guard key != loadedKey else { return }
        stopListening()
        loadedKey = key

        careServices = ownMemberships.filter { $0.orgType == .pflegedienst }
        let sources = ownMemberships.filter { $0.orgType != .pflegedienst }
        entries = careServices.isEmpty ? [] : sources.map { SharingEntry(source: $0, linkedOrgIds: []) }
        guard !careServices.isEmpty else { return }

        // Freigaben je Praxis live beobachten
        for source in sources {
            guard let orgId = source.orgId else { continue }
            listeners.append(container.prescriptions.listenLinkedOrgs(orgId: orgId, patientId: uid) { [weak self] links in
                guard let self, let index = self.entries.firstIndex(where: { $0.source.orgId == orgId }) else { return }
                self.entries[index].linkedOrgIds = Set(links.map(\.orgId))
            })
        }
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners = []
        loadedKey = ""
    }

    func toggle(_ entry: SharingEntry, careService: Membership) {
        guard let uid = container.auth.currentUserId,
              let sourceId = entry.source.orgId,
              let careId = careService.orgId else { return }
        var ids = entry.linkedOrgIds
        if ids.contains(careId) {
            ids.remove(careId)
        } else {
            ids.insert(careId)
        }
        let links = careServices
            .filter { ids.contains($0.orgId ?? "") }
            .map { LinkedOrg(orgId: $0.orgId ?? "", orgName: $0.orgName) }

        Task {
            do {
                try await container.prescriptions.setLinkedOrgs(links, orgId: sourceId, patientId: uid)
            } catch {
                message = tr("Freigabe konnte nicht gespeichert werden: {0}", error.localizedDescription)
            }
        }
    }
}
