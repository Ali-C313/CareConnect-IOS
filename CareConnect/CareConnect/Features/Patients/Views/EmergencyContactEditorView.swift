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
            ScrollView {
                VStack(spacing: 20) {
                    // Allgemein
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Allgemein", systemImage: "person.text.rectangle")
                            .font(.headline)
                            .foregroundColor(CCDesign.textPrimary)

                        Group {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(CCDesign.accent)
                                TextField("Name", text: $viewModel.newEmergencyContact.name)
                                    .foregroundColor(CCDesign.textPrimary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))

                            HStack {
                                Image(systemName: "heart.text.square")
                                    .foregroundColor(CCDesign.accent)
                                TextField("Beziehung (z. B. Ehepartner)", text: Binding(
                                    get: { viewModel.newEmergencyContact.relation ?? "" },
                                    set: { viewModel.newEmergencyContact.relation = $0 }
                                ))
                                .foregroundColor(CCDesign.textPrimary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))

                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(CCDesign.accent)
                                TextField("Alter", value: $viewModel.newEmergencyContact.age, format: .number)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(CCDesign.textPrimary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)

                    // Kontaktinformationen
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Kontaktinformationen", systemImage: "phone.text.fill")
                            .font(.headline)
                            .foregroundColor(CCDesign.textPrimary)

                        Group {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(CCDesign.accent)
                                TextField("Telefonnummer", text: Binding(
                                    get: { viewModel.newEmergencyContact.phone ?? "" },
                                    set: { viewModel.newEmergencyContact.phone = $0 }
                                ))
                                .keyboardType(.phonePad)
                                .foregroundColor(CCDesign.textPrimary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))

                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(CCDesign.accent)
                                TextField("E-Mail-Adresse", text: Binding(
                                    get: { viewModel.newEmergencyContact.email ?? "" },
                                    set: { viewModel.newEmergencyContact.email = $0 }
                                ))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.emailAddress)
                                .foregroundColor(CCDesign.textPrimary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(CCDesign.accent)
                                    TextField("Adresse", text: $addressVM.queryFragment)
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                        .foregroundColor(CCDesign.textPrimary)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(CCDesign.card))

                                if !addressVM.suggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(addressVM.suggestions, id: \.self) { suggestion in
                                            Button {
                                                viewModel.newEmergencyContact.address = suggestion
                                                addressVM.queryFragment = suggestion
                                                addressVM.suggestions = []
                                            } label: {
                                                HStack {
                                                    Image(systemName: "location.fill")
                                                        .foregroundColor(CCDesign.accent)
                                                    Text(suggestion)
                                                        .foregroundColor(CCDesign.textPrimary)
                                                        .lineLimit(2)
                                                    Spacer()
                                                }
                                                .padding(8)
                                                .background(RoundedRectangle(cornerRadius: 8).fill(CCDesign.background.opacity(0.5)))
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(CCDesign.background.ignoresSafeArea())
            .navigationTitle("Notfallkontakt hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            await viewModel.saveEmergencyContact()
                            dismiss()
                        }
                    }
                    .tint(CCDesign.accent)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .tint(CCDesign.accent)
                }
            }
        }
    }
}


#Preview {
    EmergencyContactEditorView(viewModel: PatientProfileViewModel())
}
