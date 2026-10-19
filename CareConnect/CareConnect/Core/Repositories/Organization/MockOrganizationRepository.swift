//
//  MockOrganizationRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Eine Beispiel-Organisation, in der man Leitung ist
final class MockOrganizationRepository: OrganizationRepository {
    private var memberships = [MockData.membership]
    private var invites: [Invite] = []

    // Mitgliedschaften
    func listenMemberships(uid: String, onChange: @escaping ([Membership]) -> Void) -> ListenerHandle {
        onChange(memberships)
        return MockListener()
    }

    func listenOrganization(orgId: String, onChange: @escaping (Organization?) -> Void) -> ListenerHandle {
        onChange(MockData.organization)
        return MockListener()
    }

    func listenMemberRole(orgId: String, uid: String, onChange: @escaping (MemberRole?) -> Void) -> ListenerHandle {
        onChange(memberships.first { $0.orgId == orgId }?.role)
        return MockListener()
    }

    func create(profile: UserProfile, name: String, type: OrganizationType, address: String) async throws -> String {
        MockData.orgId
    }

    func leave(uid: String, orgId: String) async throws {
        memberships.removeAll { $0.orgId == orgId }
    }

    // Einladungscodes
    func listenInvites(orgId: String, onChange: @escaping ([Invite]) -> Void) -> ListenerHandle {
        onChange(invites)
        return MockListener()
    }

    func findInvite(code: String) async throws -> Invite? {
        invites.first { $0.code == code }
    }

    func join(profile: UserProfile, invite: Invite) async throws {}

    func createInvite(orgId: String, role: MemberRole) async throws {
        var invite = Invite(orgId: orgId, orgName: MockData.organization.name, role: role)
        invite.code = String(UUID().uuidString.prefix(6))
        invites.append(invite)
    }

    func deleteInvite(orgId: String, code: String) async throws {
        invites.removeAll { $0.code == code }
    }

    // Suche und Beitrittsanfragen
    func search(_ query: String) async throws -> [Organization] {
        [MockData.organization].filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func listenIsListed(orgId: String, onChange: @escaping (Bool) -> Void) -> ListenerHandle {
        onChange(true)
        return MockListener()
    }

    func setListed(orgId: String, listed: Bool) async throws {}

    func sendJoinRequest(profile: UserProfile, organization: Organization) async throws {}

    func listenMyJoinRequests(uid: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle {
        onChange([])
        return MockListener()
    }

    func cancelJoinRequest(uid: String, orgId: String) async throws {}

    func completeAcceptedRequest(uid: String, request: JoinRequest) async throws {}

    func listenJoinRequests(orgId: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle {
        onChange([])
        return MockListener()
    }

    func accept(_ request: JoinRequest) async throws {}

    func decline(_ request: JoinRequest) async throws {}

    // Mitglieder verwalten
    func listenMembers(orgId: String, onChange: @escaping ([Member]) -> Void) -> ListenerHandle {
        var member = Member(role: .admin, firstName: MockData.profile.firstName, lastName: MockData.profile.lastName)
        member.uid = MockData.employeeId
        onChange([member])
        return MockListener()
    }

    func updateMemberRole(orgId: String, uid: String, role: MemberRole) async throws {}

    func removeMember(orgId: String, uid: String) async throws {}
}
