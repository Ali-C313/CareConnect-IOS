//
//  OrganizationViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Organisation per Code beitreten, per Suche anfragen oder neu gründen
@MainActor
@Observable
final class OrganizationViewModel {
    var code = ""
    var orgName = ""
    var orgType: OrganizationType = .pflegedienst
    var orgAddress = ""
    var searchText = ""
    private(set) var searchResults: [Organization] = []
    private(set) var isSearching = false
    private(set) var isLoading = false
    var errorMessage: String?
    /// Eigene offene oder abgelehnte Anfragen
    private(set) var myRequests: [JoinRequest] = []

    private let auth: AuthRepository
    private let users: UserRepository
    private let organizations: OrganizationRepository
    private var listener: ListenerHandle?
    private var searchTask: Task<Void, Never>?

    init(
        auth: AuthRepository? = nil,
        users: UserRepository? = nil,
        organizations: OrganizationRepository? = nil
    ) {
        self.auth = auth ?? AppContainer.shared.auth
        self.users = users ?? AppContainer.shared.users
        self.organizations = organizations ?? AppContainer.shared.organizations
    }

    func startListening() {
        guard let uid = auth.currentUserId, listener == nil else { return }
        listener = organizations.listenMyJoinRequests(uid: uid) { [weak self] requests in
            self?.myRequests = requests
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    /// Kurz warten, damit nicht bei jedem Buchstaben gesucht wird
    func search() {
        searchTask?.cancel()
        let text = searchText
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            isSearching = true
            let results = (try? await organizations.search(text)) ?? []
            if !Task.isCancelled { searchResults = results }
            isSearching = false
        }
    }

    /// Als Patient bei einer gefundenen Organisation anfragen
    func sendRequest(to organization: Organization, memberships: [Membership]) {
        if memberships.contains(where: { $0.orgId == organization.id }) {
            errorMessage = tr("Du bist dort schon Mitglied.")
            return
        }
        if myRequests.contains(where: { $0.orgId == organization.id }) {
            errorMessage = tr("Du hast dort schon angefragt.")
            return
        }
        runWithProfile { profile in
            try await self.organizations.sendJoinRequest(profile: profile, organization: organization)
        } errorText: { tr("Anfrage fehlgeschlagen: {0}", $0) }
    }

    func cancelRequest(orgId: String) {
        guard let uid = auth.currentUserId else { return }
        Task { try? await organizations.cancelJoinRequest(uid: uid, orgId: orgId) }
    }

    func join(memberships: [Membership]) {
        guard !code.isBlank else {
            errorMessage = tr("Bitte den Einladungscode eingeben.")
            return
        }
        let code = code
        runWithProfile { profile in
            guard let invite = try await self.organizations.findInvite(code: code) else {
                throw AppError.invalidInput(tr("Der Einladungscode ist ungültig."))
            }
            // Schon Mitglied → nur dorthin wechseln
            if memberships.contains(where: { $0.orgId == invite.orgId }) {
                try await self.users.setActiveOrg(uid: profile.uid, orgId: invite.orgId)
            } else {
                try await self.organizations.join(profile: profile, invite: invite)
            }
        } errorText: { tr("Beitritt fehlgeschlagen: {0}", $0) }
    }

    func create() {
        guard !orgName.isBlank else {
            errorMessage = tr("Bitte einen Namen für die Organisation eingeben.")
            return
        }
        let name = orgName.trimmed
        let type = orgType
        let address = orgAddress.trimmed
        runWithProfile { profile in
            _ = try await self.organizations.create(profile: profile, name: name, type: type, address: address)
        } errorText: { tr("Organisation konnte nicht angelegt werden: {0}", $0) }
    }

    /// Lädt das eigene Profil und führt die Aktion aus, Fehler landen in errorMessage
    private func runWithProfile(
        _ action: @escaping (UserProfile) async throws -> Void,
        errorText: @escaping (String) -> String
    ) {
        guard let uid = auth.currentUserId, !isLoading else { return }
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                guard let profile = try await users.fetch(uid: uid) else {
                    errorMessage = tr("Dein Profil wurde nicht gefunden.")
                    return
                }
                try await action(profile)
                resetForm()
            } catch AppError.invalidInput(let text) {
                errorMessage = text
            } catch {
                errorMessage = errorText(error.localizedDescription)
            }
        }
    }

    private func resetForm() {
        code = ""
        orgName = ""
        orgAddress = ""
        searchText = ""
        searchResults = []
    }
}
