//
//  UserProfile.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Eigenes Profil unter users/{uid}, unabhängig von der Organisation
struct UserProfile: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var birthDate: Timestamp?
    var address: String = ""
    var city: String = ""
    var phone: String = ""
    var profileImageURL: String = ""
    var activeOrgId: String?
    var createdAt: Timestamp?

    var uid: String { id ?? "" }

    var name: String { "\(firstName) \(lastName)".trimmed }
}
