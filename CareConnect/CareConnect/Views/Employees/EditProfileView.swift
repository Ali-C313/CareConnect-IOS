//
//  EditProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var employee: Employee
    private let service: FirebaseServiceType = FirebaseLiveService()

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isUploading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profilbild") {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                                    .opacity(0.7)
                            }

                            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                                Label("Bild auswählen", systemImage: "photo.on.rectangle")
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
                        Spacer()
                    }
                }
                Section("Allgemein") {
                    TextField("Vorname", text: $employee.firstName)
                    TextField("Nachname", text: $employee.lastName)
                    TextField("Rolle", text: $employee.role)
                    TextField("E-Mail", text: $employee.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .navigationTitle("Profil bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task { await save() }
                    }
                }
            }
        }
    }

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
