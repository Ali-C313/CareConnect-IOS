//
//  OrganizationRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

protocol OrganizationRepository {
    // Mitgliedschaften
    func listenMemberships(uid: String, onChange: @escaping ([Membership]) -> Void) -> ListenerHandle
    func listenOrganization(orgId: String, onChange: @escaping (Organization?) -> Void) -> ListenerHandle
    /// nil = kein Mitglied (mehr)
    func listenMemberRole(orgId: String, uid: String, onChange: @escaping (MemberRole?) -> Void) -> ListenerHandle
    /// - Returns: ID der neuen Organisation
    func create(profile: UserProfile, name: String, type: OrganizationType, address: String) async throws -> String
    func leave(uid: String, orgId: String) async throws

    // Einladungscodes
    func listenInvites(orgId: String, onChange: @escaping ([Invite]) -> Void) -> ListenerHandle
    func findInvite(code: String) async throws -> Invite?
    func join(profile: UserProfile, invite: Invite) async throws
    func createInvite(orgId: String, role: MemberRole) async throws
    func deleteInvite(orgId: String, code: String) async throws

    // Suche und Beitrittsanfragen
    func search(_ query: String) async throws -> [Organization]
    func listenIsListed(orgId: String, onChange: @escaping (Bool) -> Void) -> ListenerHandle
    func setListed(orgId: String, listed: Bool) async throws
    func sendJoinRequest(profile: UserProfile, organization: Organization) async throws
    func listenMyJoinRequests(uid: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle
    func cancelJoinRequest(uid: String, orgId: String) async throws
    func completeAcceptedRequest(uid: String, request: JoinRequest) async throws
    func listenJoinRequests(orgId: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle
    func accept(_ request: JoinRequest) async throws
    func decline(_ request: JoinRequest) async throws

    // Mitglieder verwalten
    func listenMembers(orgId: String, onChange: @escaping ([Member]) -> Void) -> ListenerHandle
    func updateMemberRole(orgId: String, uid: String, role: MemberRole) async throws
    func removeMember(orgId: String, uid: String) async throws
}
