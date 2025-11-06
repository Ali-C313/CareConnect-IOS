//
//  RegisterView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
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
                VStack(spacing: 20) {
                    Text("Registrieren").font(.largeTitle.bold()).padding(.top)

                    ImagePicker(selectedImage: $selectedImage).padding(.bottom, 8)

                    Group {
                        TextField("Vorname", text: $firstName).textFieldStyle(.roundedBorder)
                        TextField("Nachname", text: $lastName).textFieldStyle(.roundedBorder)

                        Picker("Rolle", selection: $selectedRole) {
                            ForEach(roles, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)

                        DatePicker("Geburtsdatum", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                        
                        if selectedRole == "Patient" {
                            VStack(alignment: .leading) {
                                TextField("Adresse", text: $addressVM.queryFragment)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(.roundedBorder)

                                if !addressVM.suggestions.isEmpty {
                                    List(addressVM.suggestions, id: \.self) { suggestion in
                                        Button {
                                            address = suggestion
                                            addressVM.queryFragment = suggestion
                                            addressVM.suggestions = []
                                        } label: {
                                            Text(suggestion)
                                                .foregroundStyle(.primary)
                                                .lineLimit(2)
                                        }
                                    }
                                    .frame(maxHeight: 150)
                                }
                            }
                            TextField("Stadt", text: $city)
                                .textFieldStyle(.roundedBorder)
                            TextField("Telefonnummer", text: $phone)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    Group {
                        TextField("E-Mail-Adresse", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        SecureField("Passwort", text: $viewModel.password).textFieldStyle(.roundedBorder)
                        SecureField("Passwort bestätigen", text: $viewModel.confirmPassword).textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).multilineTextAlignment(.center).padding(.horizontal)
                    }

                    Button {
                        Task { await registerUser() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Konto erstellen")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    .disabled(viewModel.isLoading)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 60)
            }
            .navigationTitle("Registrieren")
        }
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
