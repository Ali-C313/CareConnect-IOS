//
//  UserRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Eigenes Profil unter users/{uid}
protocol UserRepository {
    func listen(uid: String, onChange: @escaping (UserProfile?) -> Void) -> ListenerHandle
    func fetch(uid: String) async throws -> UserProfile?
    func create(_ profile: UserProfile, uid: String) async throws
    func setActiveOrg(uid: String, orgId: String) async throws
}
