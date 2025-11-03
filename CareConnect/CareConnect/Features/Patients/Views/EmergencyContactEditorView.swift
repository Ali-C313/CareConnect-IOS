//
//  EmergencyContactEditorView.swift
//  CareConnect
//
//  Created by Ali Chehab on 24.10.25.
//

import SwiftUI
import FirebaseFirestore

struct EmergencyContactEditorView: View {
    /// Profil-ViewModel
    @ObservedObject var viewModel: PatientProfileViewModel
    /// Schließen
    @Environment(\.dismiss) private var dismiss
    
    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Allgemein")) {
                    TextField("Name", text: $viewModel.newEmergencyContact.name)
                    
                    TextField("Beziehung (z. B. Ehepartner)",
                              text: Binding(
                                  get: { viewModel.newEmergencyContact.relation ?? "" },
                                  set: { viewModel.newEmergencyContact.relation = $0 }
                              )
                    )
                    
                    TextField("Alter", value: $viewModel.newEmergencyContact.age, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Kontaktinformationen")) {
                    TextField("Telefonnummer",
                              text: Binding(
                                get: { viewModel.newEmergencyContact.phone ?? "" },
                                set: { viewModel.newEmergencyContact.phone = $0 }
                              )
                    )
                    TextField("E-Mail-Adresse",
                              text: Binding(
                                get: { viewModel.newEmergencyContact.email ?? "" },
                                set: { viewModel.newEmergencyContact.email = $0 }
                              )
                    )
                    TextField("Adresse",
                              text: Binding(
                                get: { viewModel.newEmergencyContact.address ?? "" },
                                set: { viewModel.newEmergencyContact.address = $0 }
                              )
                    )
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
