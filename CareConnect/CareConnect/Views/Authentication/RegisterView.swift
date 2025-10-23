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
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss

    // zusätzliche Felder
    @State private var selectedImage: UIImage?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole = "Mitarbeiter"
    @State private var birthDate = Date(timeIntervalSince1970: 946684800) // 2000-01-01
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

    // MARK: Registrierung inkl. Storage Upload + Firestore
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
                        "role": "Pflegekraft",
                        "status": StaffStatus.available.rawValue
                    ]) { $1 }, merge: true)
            } else {
                try await db.collection("patients").document(user.uid)
                    .setData(common.merging([
                        "address": "",
                        "phone":   "",
                        "notes":   ""
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
