//
//  EditPatientProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import UIKit

/// Eigenes Patientenprofil bearbeiten
@MainActor
@Observable
final class EditPatientProfileViewModel {
    var firstName = ""
    var lastName = ""
    var address = ""
    var city = ""
    var email = ""
    var phone = ""
    var allergies = ""
    var medicalHistory = ""
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
    func load(from patient: Patient?) {
        guard !didLoad, let patient else { return }
        firstName = patient.firstName ?? ""
        lastName = patient.lastName ?? ""
        address = patient.address ?? ""
        city = patient.city ?? ""
        email = patient.email ?? ""
        phone = patient.phone ?? ""
        allergies = patient.allergies ?? ""
        medicalHistory = patient.medicalHistory ?? ""
        profileImageURL = patient.profileImageURL ?? ""
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
                "address": address.trimmed,
                "city": city.trimmed,
                "email": email.trimmed,
                "phone": phone.trimmed,
                "allergies": allergies.trimmed,
                "medicalHistory": medicalHistory.trimmed
            ]
            if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                let url = try await container.storage.upload(data: data, path: "profileImages/\(uid).jpg", contentType: "image/jpeg")
                fields["profileImageURL"] = url
            }
            try await container.patients.updateProfile(orgId: orgId, id: uid, fields: fields)
            return true
        } catch {
            message = tr("Fehler beim Speichern: {0}", error.localizedDescription)
            return false
        }
    }
}
