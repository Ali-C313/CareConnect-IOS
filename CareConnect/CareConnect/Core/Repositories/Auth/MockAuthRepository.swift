//
//  MockAuthRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Login ohne Firebase, immer als Beispiel-Mitarbeiter angemeldet
final class MockAuthRepository: AuthRepository {
    private var userId: String? = MockData.employeeId

    var currentUserId: String? { userId }
    var currentEmail: String? { userId == nil ? nil : MockData.profile.email }

    func listenAuthState(onChange: @escaping (String?) -> Void) -> ListenerHandle {
        onChange(userId)
        return MockListener()
    }

    func signIn(email: String, password: String) async throws {
        userId = MockData.employeeId
    }

    func register(email: String, password: String) async throws -> String {
        MockData.employeeId
    }

    func signOut() throws {
        userId = nil
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {}

    func saveMessagingToken(_ token: String) async {}
}
