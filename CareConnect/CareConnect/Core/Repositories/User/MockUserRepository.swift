//
//  MockUserRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Profil aus den Beispieldaten
final class MockUserRepository: UserRepository {
    private var profile: UserProfile? = MockData.profile

    func listen(uid: String, onChange: @escaping (UserProfile?) -> Void) -> ListenerHandle {
        onChange(profile)
        return MockListener()
    }

    func fetch(uid: String) async throws -> UserProfile? {
        profile
    }

    func create(_ profile: UserProfile, uid: String) async throws {
        self.profile = profile
    }

    func setActiveOrg(uid: String, orgId: String) async throws {
        profile?.activeOrgId = orgId
    }
}
