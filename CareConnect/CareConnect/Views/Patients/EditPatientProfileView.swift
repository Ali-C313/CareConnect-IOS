//
//  EditPatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 24.10.25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth

struct EditPatientProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppStateViewModel
    @Binding var patient: Patient
    private let service: FirebaseServiceType = FirebaseLiveService()

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isUploading = false

    var body: some View {
        NavigationStack {
            Form {
                // 🔹 Profilbild
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
                            .onChange(of: selectedPhoto) { oldValue, newValue in
                                guard let item = newValue else { return }
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        profileImage = uiImage
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                
                // 🔹 Allgemeine Informationen
                Section("Allgemein") {
                    TextField("Vorname", text: Binding(
                        get: { patient.firstName ?? "" },
                        set: { patient.firstName = $0 }
                    ))
                    TextField("Nachname", text: Binding(
                        get: { patient.lastName ?? "" },
                        set: { patient.lastName = $0 }
                    ))
                    TextField("Adresse", text: Binding(
                        get: { patient.address ?? "" },
                        set: { patient.address = $0 }
                    ))
                    TextField("Stadt", text: Binding(
                        get: { patient.city ?? "" },
                        set: { patient.city = $0 }
                    ))
                    TextField("E-Mail", text: Binding(
                        get: { patient.email ?? "" },
                        set: { patient.email = $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    TextField("Telefonnummer", text: Binding(
                        get: { patient.phone ?? "" },
                        set: { patient.phone = $0 }
                    ))
                }
                
                // 🔹 Medizinische Informationen
                Section("Medizinisch") {
                    TextField("Alter", text: Binding(
                        get: { patient.age.map(String.init) ?? "" },
                        set: { patient.age = Int($0.filter { $0.isNumber }) }
                    ))
                    .keyboardType(.numberPad)
                    TextField("Allergien", text: Binding(
                        get: { patient.allergies ?? "" },
                        set: { patient.allergies = $0 }
                    ))
                    TextField("Krankengeschichte", text: Binding(
                        get: { patient.medicalHistory ?? "" },
                        set: { patient.medicalHistory = $0 }
                    ))
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
        let uid = Auth.auth().currentUser?.uid ?? ""
        let id = uid
        do {
            var fields: [String: Any] = [
                "name": "\(patient.firstName) \(patient.lastName)",
                "uid": uid,
                "firstName": patient.firstName,
                "lastName": patient.lastName,
                "address": patient.address,
                "city": patient.city,
                "email": patient.email as Any,
                "phone": patient.phone as Any,
                "age": patient.age as Any,
                "allergies": patient.allergies as Any,
                "medicalHistory": patient.medicalHistory as Any
            ]

            if let image = profileImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                isUploading = true
                let storageRef = Storage.storage().reference().child("patient_images/\(id).jpg")
                _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                fields["profileImageURL"] = downloadURL.absoluteString
                patient.profileImageURL = downloadURL.absoluteString
                isUploading = false
            }

            try await service.updatePatient(id: id, fields: fields)
            await appState.loadCurrentPatient()
            dismiss()
        } catch {
            isUploading = false
            print("❌ Fehler beim Speichern:", error.localizedDescription)
        }
    }
}

#Preview {
    // Beispiel-Demo-Patient für Xcode Canvas
    EditPatientProfileView(patient: .constant(Patient(
        id: "patient001",
        firstName: "",
        lastName: "",
        address: "",
        phone: "",
        email: "",
        allergies: "",
        medicalHistory: "",
        age: 42,
        city: ""
    )))
    .preferredColorScheme(.dark)
}
