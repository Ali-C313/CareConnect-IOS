//
//  UserRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

final class UserRepositoryImpl: UserRepository {
    private var ref: CollectionReference { FirebaseManager.shared.database.collection(CollectionNames.users) }

    func listen(uid: String, onChange: @escaping (UserProfile?) -> Void) -> ListenerHandle {
        ref.document(uid).listen(as: UserProfile.self, onChange: onChange)
    }

    func fetch(uid: String) async throws -> UserProfile? {
        let document = try await ref.document(uid).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: UserProfile.self)
    }

    func create(_ profile: UserProfile, uid: String) async throws {
        var profile = profile
        profile.createdAt = Timestamp()
        try ref.document(uid).setData(from: profile, merge: true)
    }

    func setActiveOrg(uid: String, orgId: String) async throws {
        try await ref.document(uid).updateData(["activeOrgId": orgId])
    }
}
