//
//  RegisterViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import UIKit
import FirebaseFirestore

/// Legt nur das Konto an, die Organisation kommt danach im Onboarding
@MainActor
@Observable
final class RegisterViewModel {
    var firstName = ""
    var lastName = ""
    var birthDate = Date(timeIntervalSince1970: 946_728_000) // 01.01.2000
    var address = ""
    var city = ""
    var phone = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var image: UIImage?
    var errorMessage: String?
    private(set) var isLoading = false

    private let auth: AuthRepository
    private let users: UserRepository
    private let storage: StorageRepository

    init(
        auth: AuthRepository? = nil,
        users: UserRepository? = nil,
        storage: StorageRepository? = nil
    ) {
        self.auth = auth ?? AppContainer.shared.auth
        self.users = users ?? AppContainer.shared.users
        self.storage = storage ?? AppContainer.shared.storage
    }

    func register() async {
        if let error = validate() {
            errorMessage = error
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let uid: String
        do {
            uid = try await auth.register(email: email, password: password)
        } catch {
            errorMessage = tr("Fehler bei der Registrierung: {0}", error.localizedDescription)
            return
        }

        // Profilbild hochladen (Fehler hier ist nicht schlimm)
        var imageURL = ""
        if let data = image?.jpegData(compressionQuality: 0.7) {
            imageURL = (try? await storage.upload(data: data, path: "profileImages/\(uid).jpg", contentType: "image/jpeg")) ?? ""
        }

        // Profil als letztes speichern, danach geht es ins Onboarding
        let profile = UserProfile(
            firstName: firstName.trimmed,
            lastName: lastName.trimmed,
            email: email.trimmed,
            birthDate: Timestamp(date: birthDate.atNoon),
            address: address.trimmed,
            city: city.trimmed,
            phone: phone.trimmed,
            profileImageURL: imageURL
        )
        do {
            try await users.create(profile, uid: uid)
        } catch {
            errorMessage = tr("Fehler beim Speichern der Profildaten: {0}", error.localizedDescription)
        }
    }

    /// Fehlermeldung oder nil, wenn alles passt
    private func validate() -> String? {
        if firstName.isBlank || lastName.isBlank { return tr("Bitte Vor- und Nachname eingeben.") }
        if !email.isValidEmail { return tr("Bitte eine gültige E-Mail-Adresse eingeben.") }
        if password.count < 6 { return tr("Das Passwort muss mindestens 6 Zeichen haben.") }
        if password != confirmPassword { return tr("Passwörter stimmen nicht überein.") }
        return nil
    }
}
