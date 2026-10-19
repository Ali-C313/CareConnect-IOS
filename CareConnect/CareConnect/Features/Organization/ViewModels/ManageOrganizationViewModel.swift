//
//  ManageOrganizationViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Nur für die Leitung: Anfragen, Codes, Mitglieder, Sichtbarkeit
@MainActor
@Observable
final class ManageOrganizationViewModel {
    private(set) var organization: Organization?
    private(set) var isListed = false
    private(set) var joinRequests: [JoinRequest] = []
    private(set) var invites: [Invite] = []
    private(set) var members: [Member] = []
    var message: String?

    private let organizations: OrganizationRepository
    private let orgId: String?
    private var listeners: [ListenerHandle] = []

    init(organizations: OrganizationRepository? = nil, orgId: String? = nil) {
        self.organizations = organizations ?? AppContainer.shared.organizations
        self.orgId = orgId ?? AppContainer.shared.currentOrgId
    }

    func startListening() {
        guard let orgId, listeners.isEmpty else { return }
        listeners = [
            organizations.listenOrganization(orgId: orgId) { [weak self] in self?.organization = $0 },
            organizations.listenIsListed(orgId: orgId) { [weak self] in self?.isListed = $0 },
            organizations.listenJoinRequests(orgId: orgId) { [weak self] in self?.joinRequests = $0 },
            organizations.listenInvites(orgId: orgId) { [weak self] in self?.invites = $0 },
            organizations.listenMembers(orgId: orgId) { [weak self] in self?.members = $0 }
        ]
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners = []
    }

    func setListed(_ listed: Bool) {
        perform(tr("Sichtbarkeit konnte nicht geändert werden")) { orgId in
            try await self.organizations.setListed(orgId: orgId, listed: listed)
        }
    }

    func accept(_ request: JoinRequest) {
        perform(tr("Anfrage konnte nicht angenommen werden")) { _ in
            try await self.organizations.accept(request)
        }
    }

    func decline(_ request: JoinRequest) {
        perform(tr("Anfrage konnte nicht abgelehnt werden")) { _ in
            try await self.organizations.decline(request)
        }
    }

    func createInvite(role: MemberRole) {
        perform(tr("Code konnte nicht erstellt werden")) { orgId in
            try await self.organizations.createInvite(orgId: orgId, role: role)
        }
    }

    func deleteInvite(_ invite: Invite) {
        perform(tr("Code konnte nicht gelöscht werden")) { orgId in
            try await self.organizations.deleteInvite(orgId: orgId, code: invite.id)
        }
    }

    func changeRole(of member: Member, to role: MemberRole) {
        perform(tr("Rolle konnte nicht geändert werden")) { orgId in
            try await self.organizations.updateMemberRole(orgId: orgId, uid: member.id, role: role)
        }
    }

    func remove(_ member: Member) {
        perform(tr("Mitglied konnte nicht entfernt werden")) { orgId in
            try await self.organizations.removeMember(orgId: orgId, uid: member.id)
        }
    }

    private func perform(_ errorText: String, _ action: @escaping (String) async throws -> Void) {
        guard let orgId else { return }
        Task {
            do {
                try await action(orgId)
            } catch {
                message = "\(errorText): \(error.localizedDescription)"
            }
        }
    }
}
