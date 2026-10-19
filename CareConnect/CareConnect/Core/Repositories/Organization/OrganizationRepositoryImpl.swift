//
//  OrganizationRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

final class OrganizationRepositoryImpl: OrganizationRepository {
    private var database: Firestore { FirebaseManager.shared.database }

    private func userRef(_ uid: String) -> DocumentReference {
        database.collection(CollectionNames.users).document(uid)
    }

    private func inviteRef(_ code: String) -> DocumentReference {
        database.collection(CollectionNames.invites).document(code)
    }

    private func directoryRef(_ orgId: String) -> DocumentReference {
        database.collection(CollectionNames.directory).document(orgId)
    }

    private func memberRef(_ orgId: String, _ uid: String) -> DocumentReference {
        database.org(orgId).collection(CollectionNames.members).document(uid)
    }

    private func requestRef(_ orgId: String, _ uid: String) -> DocumentReference {
        database.org(orgId).collection(CollectionNames.joinRequests).document(uid)
    }

    private func myRequestRef(_ uid: String, _ orgId: String) -> DocumentReference {
        userRef(uid).collection(CollectionNames.joinRequests).document(orgId)
    }

    private func membershipRef(_ uid: String, _ orgId: String) -> DocumentReference {
        userRef(uid).collection(CollectionNames.memberships).document(orgId)
    }

    // MARK: - Mitgliedschaften

    func listenMemberships(uid: String, onChange: @escaping ([Membership]) -> Void) -> ListenerHandle {
        userRef(uid).collection(CollectionNames.memberships).listen(as: Membership.self) { list in
            onChange(list.sorted { $0.orgName < $1.orgName })
        }
    }

    func listenOrganization(orgId: String, onChange: @escaping (Organization?) -> Void) -> ListenerHandle {
        database.org(orgId).listen(as: Organization.self, onChange: onChange)
    }

    // Fehler (z. B. alte Regeln) zählen nicht als "entfernt", sonst würde die Mitgliedschaft gelöscht
    func listenMemberRole(orgId: String, uid: String, onChange: @escaping (MemberRole?) -> Void) -> ListenerHandle {
        memberRef(orgId, uid).listen(as: Member.self, ignoreErrors: true) { member in
            onChange(member?.role)
        }
    }

    func create(profile: UserProfile, name: String, type: OrganizationType, address: String) async throws -> String {
        let orgId = newId()
        let batch = database.batch()
        batch.setData([
            "name": name,
            "type": type.rawValue,
            "address": address,
            "ownerId": profile.uid,
            "createdAt": Timestamp()
        ], forDocument: database.org(orgId))
        addMember(batch, orgId: orgId, orgName: name, orgType: type, profile: profile, role: .admin, inviteCode: nil)
        // In der Suche sichtbar, kann die Leitung später ausschalten
        batch.setData([
            "name": name,
            "nameLower": name.lowercased(),
            "type": type.rawValue,
            "address": address
        ], forDocument: directoryRef(orgId))
        // Je ein Code für Mitarbeiter und Patienten
        addInvite(batch, orgId: orgId, orgName: name, orgType: type, role: .staff, createdBy: profile.uid)
        addInvite(batch, orgId: orgId, orgName: name, orgType: type, role: .patient, createdBy: profile.uid)
        try await batch.commit()
        return orgId
    }

    func leave(uid: String, orgId: String) async throws {
        let batch = database.batch()
        batch.deleteDocument(memberRef(orgId, uid))
        batch.deleteDocument(membershipRef(uid, orgId))
        try await batch.commit()
    }

    // MARK: - Einladungscodes

    // Kopie der Codes unter der Organisation, damit die Leitung sie auflisten kann
    func listenInvites(orgId: String, onChange: @escaping ([Invite]) -> Void) -> ListenerHandle {
        database.org(orgId).collection(CollectionNames.invites).listen(as: Invite.self) { invites in
            onChange(invites.sorted { $0.role.sortIndex < $1.role.sortIndex })
        }
    }

    func findInvite(code: String) async throws -> Invite? {
        let cleaned = code.trimmed.uppercased()
        guard !cleaned.isEmpty else { return nil }
        let document = try await inviteRef(cleaned).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: Invite.self)
    }

    func join(profile: UserProfile, invite: Invite) async throws {
        let batch = database.batch()
        addMember(batch, orgId: invite.orgId, orgName: invite.orgName, orgType: invite.orgType,
                  profile: profile, role: invite.role, inviteCode: invite.code)
        try await batch.commit()
    }

    func createInvite(orgId: String, role: MemberRole) async throws {
        // Erst laden, dann hier umwandeln (Codable der Modelle läuft auf dem MainActor)
        let snapshot = try await database.org(orgId).getDocument()
        let organization = try snapshot.data(as: Organization.self)
        let batch = database.batch()
        addInvite(batch, orgId: orgId, orgName: organization.name, orgType: organization.type,
                  role: role, createdBy: organization.ownerId ?? "")
        try await batch.commit()
    }

    func deleteInvite(orgId: String, code: String) async throws {
        let batch = database.batch()
        batch.deleteDocument(inviteRef(code))
        batch.deleteDocument(database.org(orgId).collection(CollectionNames.invites).document(code))
        try await batch.commit()
    }

    // MARK: - Suche und Beitrittsanfragen

    func search(_ query: String) async throws -> [Organization] {
        let text = query.trimmed.lowercased()
        guard text.count >= 2 else { return [] }
        // Wenige Einträge, deshalb reicht Filtern in der App
        let snapshot = try await database.collection(CollectionNames.directory).getDocuments()
        let results = snapshot.documents
            .compactMap { try? $0.data(as: Organization.self) }
            .filter { $0.name.lowercased().contains(text) || ($0.address ?? "").lowercased().contains(text) }
            .sorted { $0.name < $1.name }
        return Array(results.prefix(20))
    }

    func listenIsListed(orgId: String, onChange: @escaping (Bool) -> Void) -> ListenerHandle {
        directoryRef(orgId).listenExists(onChange: onChange)
    }

    func setListed(orgId: String, listed: Bool) async throws {
        guard listed else {
            try await directoryRef(orgId).delete()
            return
        }
        // Erst laden, dann hier umwandeln (Codable der Modelle läuft auf dem MainActor)
        let snapshot = try await database.org(orgId).getDocument()
        let organization = try snapshot.data(as: Organization.self)
        try await directoryRef(orgId).setData([
            "name": organization.name,
            "nameLower": organization.name.lowercased(),
            "type": organization.type.rawValue,
            "address": organization.address ?? ""
        ])
    }

    func sendJoinRequest(profile: UserProfile, organization: Organization) async throws {
        guard let orgId = organization.id else { throw AppError.missingId }
        let request = JoinRequest(
            orgId: orgId,
            orgName: organization.name,
            orgType: organization.type,
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            address: profile.address,
            city: profile.city,
            phone: profile.phone,
            birthDate: profile.birthDate,
            profileImageURL: profile.profileImageURL,
            status: .pending,
            createdAt: Timestamp()
        )
        let batch = database.batch()
        try batch.setData(from: request, forDocument: requestRef(orgId, profile.uid))
        batch.setData(["orgId": orgId, "createdAt": Timestamp()], forDocument: myRequestRef(profile.uid, orgId))
        try await batch.commit()
    }

    // Eigene Anfragen: IDs beim Nutzer, Status bei der Organisation
    func listenMyJoinRequests(uid: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle {
        MyJoinRequestsListener(
            idsRef: userRef(uid).collection(CollectionNames.joinRequests),
            requestRef: { [weak self] orgId in self?.requestRef(orgId, uid) },
            onChange: onChange
        )
    }

    func cancelJoinRequest(uid: String, orgId: String) async throws {
        let batch = database.batch()
        batch.deleteDocument(requestRef(orgId, uid))
        batch.deleteDocument(myRequestRef(uid, orgId))
        try await batch.commit()
    }

    // Leitung hat angenommen → Mitgliedschaft beim Nutzer eintragen und Anfrage aufräumen
    func completeAcceptedRequest(uid: String, request: JoinRequest) async throws {
        let batch = database.batch()
        batch.setData([
            "orgName": request.orgName,
            "orgType": request.orgType.rawValue,
            "role": MemberRole.patient.rawValue,
            "joinedAt": Timestamp()
        ], forDocument: membershipRef(uid, request.orgId))
        batch.updateData(["activeOrgId": request.orgId], forDocument: userRef(uid))
        batch.deleteDocument(requestRef(request.orgId, uid))
        batch.deleteDocument(myRequestRef(uid, request.orgId))
        try await batch.commit()
    }

    func listenJoinRequests(orgId: String, onChange: @escaping ([JoinRequest]) -> Void) -> ListenerHandle {
        database.org(orgId).collection(CollectionNames.joinRequests).listen(as: JoinRequest.self) { list in
            onChange(list
                .filter { $0.status == .pending }
                .sorted { ($0.createdAt?.date ?? .distantPast) < ($1.createdAt?.date ?? .distantPast) })
        }
    }

    func accept(_ request: JoinRequest) async throws {
        guard let uid = request.uid else { throw AppError.missingId }
        let now = Timestamp()
        let batch = database.batch()
        batch.setData([
            "role": MemberRole.patient.rawValue,
            "firstName": request.firstName,
            "lastName": request.lastName,
            "joinedAt": now
        ], forDocument: memberRef(request.orgId, uid))
        var patient: [String: Any] = [
            "uid": uid,
            "firstName": request.firstName,
            "lastName": request.lastName,
            "address": request.address,
            "city": request.city,
            "phone": request.phone,
            "email": request.email,
            "profileImageURL": request.profileImageURL,
            "createdAt": now
        ]
        if let birthDate = request.birthDate { patient["birthDate"] = birthDate }
        let patientRef = database.org(request.orgId).collection(CollectionNames.patients).document(uid)
        batch.setData(patient, forDocument: patientRef, merge: true)
        batch.updateData(["status": JoinRequestStatus.accepted.rawValue], forDocument: requestRef(request.orgId, uid))
        try await batch.commit()
    }

    func decline(_ request: JoinRequest) async throws {
        guard let uid = request.uid else { throw AppError.missingId }
        try await requestRef(request.orgId, uid).updateData(["status": JoinRequestStatus.declined.rawValue])
    }

    // MARK: - Mitglieder

    func listenMembers(orgId: String, onChange: @escaping ([Member]) -> Void) -> ListenerHandle {
        database.org(orgId).collection(CollectionNames.members).listen(as: Member.self) { members in
            onChange(members.sorted {
                $0.role.sortIndex == $1.role.sortIndex ? $0.name < $1.name : $0.role.sortIndex < $1.role.sortIndex
            })
        }
    }

    func updateMemberRole(orgId: String, uid: String, role: MemberRole) async throws {
        try await memberRef(orgId, uid).updateData(["role": role.rawValue])
    }

    func removeMember(orgId: String, uid: String) async throws {
        try await memberRef(orgId, uid).delete()
    }

    // MARK: - Hilfsfunktionen

    /// Mitglied + Profil in der Organisation + Eintrag beim Nutzer
    private func addMember(
        _ batch: WriteBatch,
        orgId: String,
        orgName: String,
        orgType: OrganizationType,
        profile: UserProfile,
        role: MemberRole,
        inviteCode: String?
    ) {
        let now = Timestamp()
        var member: [String: Any] = [
            "role": role.rawValue,
            "firstName": profile.firstName,
            "lastName": profile.lastName,
            "joinedAt": now
        ]
        if let inviteCode { member["inviteCode"] = inviteCode }
        batch.setData(member, forDocument: memberRef(orgId, profile.uid))

        var person: [String: Any] = [
            "uid": profile.uid,
            "firstName": profile.firstName,
            "lastName": profile.lastName,
            "email": profile.email,
            "profileImageURL": profile.profileImageURL
        ]
        if let birthDate = profile.birthDate { person["birthDate"] = birthDate }

        let orgRef = database.org(orgId)
        if role == .patient {
            person["address"] = profile.address
            person["city"] = profile.city
            person["phone"] = profile.phone
            person["createdAt"] = now
            batch.setData(person, forDocument: orgRef.collection(CollectionNames.patients).document(profile.uid), merge: true)
        } else {
            person["role"] = role == .admin ? "Leitung" : "Pflegekraft"
            person["status"] = StaffStatus.available.rawValue
            if let inviteCode { person["inviteCode"] = inviteCode }
            batch.setData(person, forDocument: orgRef.collection(CollectionNames.employees).document(profile.uid), merge: true)
        }

        batch.setData([
            "orgName": orgName,
            "orgType": orgType.rawValue,
            "role": role.rawValue,
            "joinedAt": now
        ], forDocument: membershipRef(profile.uid, orgId))
        batch.updateData(["activeOrgId": orgId], forDocument: userRef(profile.uid))
    }

    /// Neuer Code bei invites und unter der Organisation
    private func addInvite(
        _ batch: WriteBatch,
        orgId: String,
        orgName: String,
        orgType: OrganizationType,
        role: MemberRole,
        createdBy: String
    ) {
        let code = generateCode()
        let data: [String: Any] = [
            "orgId": orgId,
            "orgName": orgName,
            "orgType": orgType.rawValue,
            "role": role.rawValue,
            "createdBy": createdBy,
            "createdAt": Timestamp()
        ]
        batch.setData(data, forDocument: inviteRef(code))
        batch.setData(data, forDocument: database.org(orgId).collection(CollectionNames.invites).document(code))
    }

    /// 8 Zeichen ohne leicht verwechselbare wie 0/O oder 1/I
    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<8).compactMap { _ in chars.randomElement() })
    }
}

/// Beobachtet die Liste der eigenen Anfragen und zu jeder Anfrage den Status bei der Organisation
private final class MyJoinRequestsListener: ListenerHandle {
    private var idsListener: ListenerRegistration?
    private var requestListeners: [String: ListenerHandle] = [:]
    private var requests: [String: JoinRequest] = [:]
    private let onChange: ([JoinRequest]) -> Void

    init(
        idsRef: CollectionReference,
        requestRef: @escaping (String) -> DocumentReference?,
        onChange: @escaping ([JoinRequest]) -> Void
    ) {
        self.onChange = onChange
        idsListener = idsRef.addSnapshotListener { [weak self] snapshot, _ in
            guard let self else { return }
            let orgIds = Set(snapshot?.documents.map(\.documentID) ?? [])
            // Weggefallene Anfragen beenden
            for (orgId, listener) in self.requestListeners where !orgIds.contains(orgId) {
                listener.remove()
                self.requestListeners[orgId] = nil
                self.requests[orgId] = nil
            }
            // Neue Anfragen beobachten
            for orgId in orgIds where self.requestListeners[orgId] == nil {
                guard let ref = requestRef(orgId) else { continue }
                self.requestListeners[orgId] = ref.listen(as: JoinRequest.self) { [weak self] request in
                    self?.requests[orgId] = request
                    self?.publish()
                }
            }
            self.publish()
        }
    }

    private func publish() {
        onChange(requests.values.sorted { $0.orgName < $1.orgName })
    }

    func remove() {
        idsListener?.remove()
        idsListener = nil
        requestListeners.values.forEach { $0.remove() }
        requestListeners = [:]
    }
}
