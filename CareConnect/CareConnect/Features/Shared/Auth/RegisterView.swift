//
//  RegisterView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
struct RegisterView: View {
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// Register-ViewModel
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss

    /// Profilbild
    @State private var selectedImage: UIImage?
    /// Vorname
    @State private var firstName = ""
    /// Nachname
    @State private var lastName = ""
    /// Benutzerrolle
    @State private var selectedRole = "Mitarbeiter"
    /// Geburtsdatum
    @State private var birthDate = Date(timeIntervalSince1970: 946684800) // 2000-01-01
    /// Adresse
    @State private var address = ""
    /// Stadt
    @State private var city = ""
    /// Telefonnummer
    @State private var phone = ""
    @StateObject private var addressVM = AddressSearchViewModel()
    private let roles = ["Mitarbeiter", "Patient"]

    init(appState: AppStateViewModel) {
        _viewModel = StateObject(wrappedValue: RegisterViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // Header
                    VStack(spacing: 8) {
                        Text("Registrieren")
                            .font(.largeTitle.bold())
                            .foregroundColor(CCDesign.accent)
                        Text("Erstelle dein CareConnect Konto")
                            .font(.subheadline)
                            .foregroundColor(CCDesign.textSecondary)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                    // Profile Image Picker
                    VStack(spacing: 10) {
                        ImagePicker(selectedImage: $selectedImage)
                            .frame(height: 160)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                        Text("Profilbild auswählen")
                            .font(.footnote.bold())
                            .foregroundColor(CCDesign.accent)
                    }
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                    // Personal Info
                    VStack(spacing: 16) {
                        customTextField("Vorname", text: $firstName, icon: "person.fill")
                        customTextField("Nachname", text: $lastName, icon: "person.fill")

                        Picker("Rolle", selection: $selectedRole) {
                            ForEach(roles, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 8)

                        DatePicker("Geburtsdatum", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
                    }
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Patient Specific Fields
                    if selectedRole == "Patient" {
                        VStack(spacing: 16) {
                            customTextField("Adresse", text: $addressVM.queryFragment, icon: "mappin.and.ellipse")
                            if !addressVM.suggestions.isEmpty {
                                ForEach(addressVM.suggestions, id: \.self) { suggestion in
                                    Button {
                                        address = suggestion
                                        addressVM.queryFragment = suggestion
                                        addressVM.suggestions = []
                                    } label: {
                                        Text(suggestion)
                                            .foregroundColor(.primary)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .background(RoundedRectangle(cornerRadius: 8).fill(CCDesign.card.opacity(0.6)))
                                }
                            }
                            customTextField("Stadt", text: $city, icon: "building.2.fill")
                            customTextField("Telefonnummer", text: $phone, icon: "phone.fill")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                        .padding(.horizontal)
                    }

                    // Credentials
                    VStack(spacing: 16) {
                        customTextField("E-Mail-Adresse", text: $viewModel.email, icon: "envelope.fill")
                        secureField("Passwort", text: $viewModel.password, icon: "lock.fill")
                        secureField("Passwort bestätigen", text: $viewModel.confirmPassword, icon: "lock.rotation.open")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Register Button
                    Button {
                        Task { await registerUser() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Konto erstellen")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(CCDesign.accent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(CCDesign.background.ignoresSafeArea())
            .navigationTitle("Registrieren")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func customTextField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(CCDesign.accent)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }

    @ViewBuilder
    private func secureField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(CCDesign.accent)
            SecureField(placeholder, text: text)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }

    /// Registrierung
    private func registerUser() async {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            viewModel.errorMessage = "Bitte Vor- und Nachname eingeben."
            return
        }
        guard let user = await viewModel.createAccount() else { return }

        let db = Firestore.firestore()
        var imageURL: String? = nil

        if let imageData = selectedImage?.jpegData(compressionQuality: 0.6) {
            do {
                let ref = Storage.storage().reference(withPath: "profileImages/\(user.uid).jpg")
                _ = try await ref.putDataAsync(imageData)
                imageURL = try await ref.downloadURL().absoluteString
            } catch {
                print("⚠️ Bild-Upload fehlgeschlagen:", error.localizedDescription)
            }
        }

        let common: [String: Any] = [
            "firstName": firstName,
            "lastName":  lastName,
            "email":     viewModel.email,
            "birthDate": Timestamp(date: birthDate),
            "profileImageURL": imageURL ?? ""
        ]

        do {
            if selectedRole == "Mitarbeiter" {
                try await db.collection("employees").document(user.uid)
                    .setData(common.merging([
                        "uid": user.uid,
                        "role": "Pflegekraft",
                        "status": StaffStatus.available.rawValue
                    ]) { $1 }, merge: true)
            } else {
                try await db.collection("patients").document(user.uid)
                    .setData(common.merging([
                        "uid": user.uid,
                        "address": address,
                        "city": city,
                        "phone": phone,
                        "notes": "",
                        "age": 0,
                        "emergencyContact": NSNull()
                    ]) { $1 }, merge: true)
            }
        } catch {
            viewModel.errorMessage = "Fehler beim Speichern der Profildaten: \(error.localizedDescription)"
            return
        }

        await MainActor.run {
            appState.setLoggedIn(user: user)
            dismiss()
        }
    }
}

#Preview {
    RegisterView(appState: AppStateViewModel())
        .environmentObject(AppStateViewModel())
}
