//
//  EditProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation
import PhotosUI
import FirebaseStorage
import FirebaseAuth

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    /// Mitarbeiterdaten
    @State var employee: Employee
    private let service: FirebaseServiceType = FirebaseLiveService()

    /// Gewähltes Foto
    @State private var selectedPhoto: PhotosPickerItem? = nil
    /// Profilbild
    @State private var profileImage: UIImage? = nil
    /// Upload-Status
    @State private var isUploading = false

    // MARK: - Change Password
    /// Aktuelles Passwort
    @State private var currentPassword: String = ""
    /// Neues Passwort
    @State private var newPassword: String = ""
    /// Passwort bestätigen
    @State private var confirmPassword: String = ""
    @State private var isChangingPassword: Bool = false
    @State private var passwordMessage: String? = nil
    @State private var showPasswordMessage: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profilbild Abschnitt
                    VStack(spacing: 12) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Bild auswählen", systemImage: "photo.on.rectangle")
                                .font(.subheadline)
                                .foregroundColor(CCDesign.accent)
                        }
                        .onChange(of: selectedPhoto) {
                            guard let selectedPhoto else { return }
                            Task {
                                if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = uiImage
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Allgemein Abschnitt
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Allgemein", systemImage: "person.text.rectangle")
                            .font(.headline)
                        Group {
                            TextField("Vorname", text: $employee.firstName)
                            TextField("Nachname", text: $employee.lastName)
                            TextField("Rolle", text: $employee.role)
                            TextField("E-Mail", text: $employee.email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card.opacity(0.7)))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Passwort Abschnitt
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Passwort ändern", systemImage: "lock")
                            .font(.headline)
                        SecureField("Aktuelles Passwort", text: $currentPassword)
                            .textContentType(.password)
                        SecureField("Neues Passwort", text: $newPassword)
                            .textContentType(.newPassword)
                        SecureField("Neues Passwort bestätigen", text: $confirmPassword)
                            .textContentType(.newPassword)

                        Button {
                            Task { await changePassword() }
                        } label: {
                            if isChangingPassword {
                                ProgressView()
                            } else {
                                Label("Passwort ändern", systemImage: "key.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.accent))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isChangingPassword)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(CCDesign.background)
            .navigationTitle("Profil bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { Task { await save() } }
                        .tint(CCDesign.accent)
                }
            }
            .alert("Fehler", isPresented: Binding(get: { false }, set: { _ in })) { }
            .alert("Passwort", isPresented: $showPasswordMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(passwordMessage ?? "")
            }
        }
    }

    /// Änderungen speichern
    private func save() async {
        guard let id = employee.id else { dismiss(); return }
        do {
            var fields: [String: Any] = [
                "firstName": employee.firstName,
                "lastName": employee.lastName,
                "role": employee.role,
                "email": employee.email
            ]

            if let image = profileImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                isUploading = true
                let storageRef = Storage.storage().reference().child("profile_images/\(id).jpg")
                _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                fields["profileImageURL"] = downloadURL.absoluteString
                isUploading = false
            }

            try await service.updateEmployee(id: id, fields: fields)
            dismiss()
        } catch {
            isUploading = false
            print("❌ Fehler beim Speichern:", error.localizedDescription)
        }
    }

    /// Benutzer neu anmelden
    private func reauthenticate(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kein eingeloggter Benutzer gefunden."])
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.reauthenticate(with: credential) { _, error in
                if let error = error { continuation.resume(throwing: error) } else { continuation.resume(returning: ()) }
            }
        }
    }

    /// Passwort aktualisieren
    private func updateUserPassword(to newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kein eingeloggter Benutzer gefunden."])
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.updatePassword(to: newPassword) { error in
                if let error = error { continuation.resume(throwing: error) } else { continuation.resume(returning: ()) }
            }
        }
    }

    /// Passwort ändern
    private func changePassword() async {
        // Basic validation
        guard !currentPassword.isEmpty else { passwordMessage = "Bitte aktuelles Passwort eingeben."; showPasswordMessage = true; return }
        guard !newPassword.isEmpty else { passwordMessage = "Bitte neues Passwort eingeben."; showPasswordMessage = true; return }
        guard newPassword == confirmPassword else { passwordMessage = "Die neuen Passwörter stimmen nicht überein."; showPasswordMessage = true; return }
        guard !employee.email.isEmpty else { passwordMessage = "Keine E-Mail-Adresse für den Benutzer gefunden."; showPasswordMessage = true; return }

        let email = employee.email

        isChangingPassword = true
        do {
            try await reauthenticate(email: email, password: currentPassword)
            try await updateUserPassword(to: newPassword)
            passwordMessage = "Passwort erfolgreich geändert."
            // clear fields
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch {
            passwordMessage = "Fehler: \(error.localizedDescription)"
        }
        isChangingPassword = false
        showPasswordMessage = true
    }
}

#Preview {
    // Beispiel-Demo-Mitarbeiter für Xcode Canvas
    EditProfileView(employee: Employee(
        id: "demo001",
        firstName: "Ali",
        lastName: "Chehab",
        role: "Außendienst",
        status: "Verfügbar",
        email: "ali.chehab@careconnect.de"
    ))
    .preferredColorScheme(.dark)
}
