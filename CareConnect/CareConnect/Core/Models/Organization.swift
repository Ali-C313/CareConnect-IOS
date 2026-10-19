//
//  Organization.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Pflegedienst, Praxis oder Klinik (organizations/{id}, in der Suche: directory/{id})
struct Organization: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String = ""
    var type: OrganizationType = .pflegedienst
    var address: String?
    var ownerId: String?
    var createdAt: Timestamp?
}

/// Eintrag unter users/{uid}/memberships/{orgId}
struct Membership: Identifiable, Codable, Hashable {
    @DocumentID var orgId: String?
    var orgName: String = ""
    var orgType: OrganizationType = .pflegedienst
    var role: MemberRole = .patient
    var joinedAt: Timestamp?

    var id: String { orgId ?? orgName }
}

/// Mitglied unter organizations/{orgId}/members/{uid}
struct Member: Identifiable, Codable, Hashable {
    @DocumentID var uid: String?
    var role: MemberRole = .patient
    var firstName: String?
    var lastName: String?
    var inviteCode: String?
    var joinedAt: Timestamp?

    var id: String { uid ?? "" }

    var name: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmed.ifBlank(tr("Unbekannt"))
    }
}

/// Einladungscode (invites/{code}, Kopie unter der Organisation)
struct Invite: Identifiable, Codable, Hashable {
    @DocumentID var code: String?
    var orgId: String = ""
    var orgName: String = ""
    var orgType: OrganizationType = .pflegedienst
    var role: MemberRole = .patient
    var createdBy: String?
    var createdAt: Timestamp?

    var id: String { code ?? "" }
}

/// Patient fragt bei einer Organisation an, statt einen Code zu haben
struct JoinRequest: Identifiable, Codable, Hashable {
    @DocumentID var uid: String?
    var orgId: String = ""
    var orgName: String = ""
    var orgType: OrganizationType = .pflegedienst
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var address: String = ""
    var city: String = ""
    var phone: String = ""
    var birthDate: Timestamp?
    var profileImageURL: String = ""
    var status: JoinRequestStatus = .pending
    var createdAt: Timestamp?

    var id: String { "\(orgId)_\(uid ?? "")" }

    var name: String { "\(firstName) \(lastName)".trimmed.ifBlank(email) }
}
