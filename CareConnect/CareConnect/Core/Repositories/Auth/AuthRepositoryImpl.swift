//
//  AuthRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthRepositoryImpl: AuthRepository {
    private var auth: Auth { FirebaseManager.shared.auth }

    var currentUserId: String? { auth.currentUser?.uid }
    var currentEmail: String? { auth.currentUser?.email }

    func listenAuthState(onChange: @escaping (String?) -> Void) -> ListenerHandle {
        let handle = auth.addStateDidChangeListener { _, user in
            onChange(user?.uid)
        }
        return AuthListener(handle: handle)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await auth.signIn(withEmail: email.trimmed, password: password)
    }

    func register(email: String, password: String) async throws -> String {
        try await auth.createUser(withEmail: email.trimmed, password: password).user.uid
    }

    func signOut() throws {
        try auth.signOut()
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = auth.currentUser, let email = user.email else {
            throw AppError.notLoggedIn
        }
        // Firebase verlangt eine frische Anmeldung
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        _ = try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }

    func saveMessagingToken(_ token: String) async {
        guard let uid = currentUserId else { return }
        try? await FirebaseManager.shared.database
            .collection(CollectionNames.users)
            .document(uid)
            .setData(["fcmToken": token], merge: true)
    }
}

/// Auth-Listener als ListenerHandle
private final class AuthListener: ListenerHandle {
    private var handle: AuthStateDidChangeListenerHandle?

    init(handle: AuthStateDidChangeListenerHandle) {
        self.handle = handle
    }

    func remove() {
        if let handle { FirebaseManager.shared.auth.removeStateDidChangeListener(handle) }
        handle = nil
    }
}
