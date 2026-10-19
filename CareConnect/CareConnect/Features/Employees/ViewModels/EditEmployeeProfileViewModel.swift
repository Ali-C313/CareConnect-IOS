//
//  EditEmployeeProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import UIKit

/// Eigenes Mitarbeiterprofil bearbeiten
@MainActor
@Observable
final class EditEmployeeProfileViewModel {
    var firstName = ""
    var lastName = ""
    var role = ""
    var email = ""
    var selectedImage: UIImage?
    private(set) var profileImageURL = ""
    private(set) var isSaving = false
    var message: String?

    private let container: AppContainer
    private var didLoad = false

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Formular einmal mit den aktuellen Daten füllen
    func load(from employee: Employee?) {
        guard !didLoad, let employee else { return }
        firstName = employee.firstName ?? ""
        lastName = employee.lastName ?? ""
        role = employee.role ?? ""
        email = employee.email ?? ""
        profileImageURL = employee.profileImageURL ?? ""
        didLoad = true
    }

    /// - Returns: true bei Erfolg
    func save() async -> Bool {
        guard let uid = container.auth.currentUserId else { return false }
        isSaving = true
        defer { isSaving = false }

        do {
            let orgId = try container.requireOrgId()
            var fields: [String: Any] = [
                "firstName": firstName.trimmed,
                "lastName": lastName.trimmed,
                "role": role.trimmed,
                "email": email.trimmed
            ]
            // Neues Bild nur hochladen, wenn eins gewählt wurde
            if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                let url = try await container.storage.upload(data: data, path: "profileImages/\(uid).jpg", contentType: "image/jpeg")
                fields["profileImageURL"] = url
            }
            try await container.employees.updateProfile(orgId: orgId, id: uid, fields: fields)
            return true
        } catch {
            message = tr("Fehler beim Speichern: {0}", error.localizedDescription)
            return false
        }
    }
}
