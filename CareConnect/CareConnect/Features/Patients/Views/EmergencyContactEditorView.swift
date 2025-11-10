//
//  EmergencyContactEditorView.swift
//  CareConnect
//
//  Created by Ali Chehab on 24.10.25.
//

import SwiftUI
import Foundation
import FirebaseFirestore

struct EmergencyContactEditorView: View {
    /// Profil-ViewModel
    @ObservedObject var viewModel: PatientProfileViewModel
    /// Schließen
    @Environment(\.dismiss) private var dismiss
    @StateObject private var addressVM = AddressSearchViewModel()
    
    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Allgemein")) {
                    // Name
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor)
                        TextField("Name", text: $viewModel.newEmergencyContact.name)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Beziehung
                    HStack {
                        Image(systemName: "heart.text.square")
                            .foregroundColor(.accentColor)
                        TextField("Beziehung (z. B. Ehepartner)", text: Binding(
                            get: { viewModel.newEmergencyContact.relation ?? "" },
                            set: { viewModel.newEmergencyContact.relation = $0 }
                        ))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Alter
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.accentColor)
                        TextField("Alter", value: $viewModel.newEmergencyContact.age, format: .number)
                            .keyboardType(.numberPad)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Section(header: Text("Kontaktinformationen")) {
                    // Telefonnummer
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor)
                        TextField("Telefonnummer", text: Binding(
                            get: { viewModel.newEmergencyContact.phone ?? "" },
                            set: { viewModel.newEmergencyContact.phone = $0 }
                        ))
                        .keyboardType(.phonePad)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // E-Mail-Adresse
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.accentColor)
                        TextField("E-Mail-Adresse", text: Binding(
                            get: { viewModel.newEmergencyContact.email ?? "" },
                            set: { viewModel.newEmergencyContact.email = $0 }
                        ))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Adresse mit Apple Maps API
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.accentColor)
                            TextField("Adresse", text: $addressVM.queryFragment)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        if !addressVM.suggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(addressVM.suggestions, id: \.self) { suggestion in
                                        Button {
                                            viewModel.newEmergencyContact.address = suggestion
                                            addressVM.queryFragment = suggestion
                                            addressVM.suggestions = []
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
                    .animation(.easeInOut, value: addressVM.suggestions)
                }
            }
            .navigationTitle("Notfallkontakt hinzufügen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            await viewModel.saveEmergencyContact()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    EmergencyContactEditorView(viewModel: PatientProfileViewModel())
}