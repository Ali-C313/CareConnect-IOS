//
//  AuthRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Login, Registrierung und Passwort
protocol AuthRepository {
    var currentUserId: String? { get }
    var currentEmail: String? { get }

    /// Meldet die UID beim Login und nil beim Logout
    func listenAuthState(onChange: @escaping (String?) -> Void) -> ListenerHandle
    func signIn(email: String, password: String) async throws
    func register(email: String, password: String) async throws -> String
    func signOut() throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func saveMessagingToken(_ token: String) async
}
