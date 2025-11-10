//
//  EditPatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 24.10.25.
//

import SwiftUI
import Foundation
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import MapKit

struct EditPatientProfileView: View {
    
    /// Schließen
    @Environment(\.dismiss) private var dismiss
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// Patientendaten
    @Binding var patient: Patient
    /// Firebase-Service
    private let service: FirebaseServiceType = FirebaseLiveService()

    /// Ausgewähltes Foto
    @State private var selectedPhoto: PhotosPickerItem? = nil
    /// Profilbild
    @State private var profileImage: UIImage? = nil
    /// Upload-Status
    @State private var isUploading = false
    
    @StateObject private var addressCompleter = AddressSearchViewModel()
    @State private var newPassword: String = ""
    @State private var showPasswordAlert = false
    @State private var passwordErrorMessage: String?

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
                    // 🔹 Vorname
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor)
                        TextField("Vorname", text: Binding(
                            get: { patient.firstName ?? "" },
                            set: { patient.firstName = $0 }
                        ))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // 🔹 Nachname
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(.accentColor)
                        TextField("Nachname", text: Binding(
                            get: { patient.lastName ?? "" },
                            set: { patient.lastName = $0 }
                        ))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // 🔹 Adresse (Apple Maps API bleibt unverändert)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.accentColor)
                            TextField("Adresse", text: Binding(
                                get: { patient.address ?? "" },
                                set: {
                                    patient.address = $0
                                    addressCompleter.queryFragment = $0
                                }
                            ))
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        if !addressCompleter.suggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(addressCompleter.suggestions, id: \.self) { suggestion in
                                        Button {
                                            patient.address = suggestion
                                            addressCompleter.suggestions.removeAll()
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "location.fill")
                                                    .foregroundColor(.blue)
                                                Text(suggestion)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(2)
                                                Spacer()
                                            }
                                            .padding(10)
                                            .background(Color(.systemGray5).opacity(0.3))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxHeight: 180)
                            .scrollIndicators(.hidden)
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: addressCompleter.suggestions)

                    // 🔹 E-Mail
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.accentColor)
                        TextField("E-Mail", text: Binding(
                            get: { patient.email ?? "" },
                            set: { patient.email = $0 }
                        ))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // 🔹 Telefonnummer
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor)
                        TextField("Telefonnummer", text: Binding(
                            get: { patient.phone ?? "" },
                            set: { patient.phone = $0 }
                        ))
                        .keyboardType(.phonePad)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                // 🔹 Medizinische Informationen
                Section("Medizinisch") {
                    // Allergien
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.accentColor)
                        TextField("Allergien", text: Binding(
                            get: { patient.allergies ?? "" },
                            set: { patient.allergies = $0 }
                        ))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Krankengeschichte
                    HStack {
                        Image(systemName: "stethoscope")
                            .foregroundColor(.accentColor)
                        TextField("Krankengeschichte", text: Binding(
                            get: { patient.medicalHistory ?? "" },
                            set: { patient.medicalHistory = $0 }
                        ))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Section("Konto & Sicherheit") {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.accentColor)
                        SecureField("Neues Passwort", text: $newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    Button {
                        Task { await changePassword() }
                    } label: {
                        Label("Passwort ändern", systemImage: "key.fill")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.accentColor.opacity(newPassword.isEmpty ? 0.3 : 1))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newPassword.isEmpty)
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
            .alert("Passwortänderung", isPresented: $showPasswordAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let message = passwordErrorMessage {
                    Text(message)
                }
            }
        }
    }

    /// Speichern
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
    
    private func changePassword() async {
        do {
            try await Auth.auth().currentUser?.updatePassword(to: newPassword)
            passwordErrorMessage = "Passwort erfolgreich geändert."
            showPasswordAlert = true
            newPassword = ""
        } catch {
            passwordErrorMessage = "Fehler beim Ändern des Passworts: \(error.localizedDescription)"
            showPasswordAlert = true
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
        city: ""
    )))
    .preferredColorScheme(.dark)
}