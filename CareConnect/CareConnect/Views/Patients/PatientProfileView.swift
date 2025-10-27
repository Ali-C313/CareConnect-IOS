//
//  PatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct PatientProfileView: View {
    
    let patientId: String
    @StateObject private var viewModel = PatientProfileViewModel()
    @State private var showEmergencyContactSheet = false
    
    var body: some View {
        ScrollView {
            if let patient = viewModel.patient {
                VStack(alignment: .leading, spacing: 16) {
                    // 🔹 Kopfbereich
                    HStack(alignment: .top, spacing: 12) {
                        AvatarView(initials: initials(from: patient.name), size: 64)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(patient.name)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("\(patient.age) Jahre")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(patient.address ?? "Keine Adresse angegeben")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(patient.city ?? "Keine Stadt angegeben")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Button {
                            showEmergencyContactSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle.badge.exclam")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Notfallkontakt anzeigen")
                    }
                    
                    Divider().background(.white.opacity(0.2))

                    // 🔹 Medikamente
                    if !patient.medications.isEmpty {
                        Text("Medikamente:")
                            .foregroundColor(.red)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(patient.medications) { med in
                                Text("• \(med.name)")
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    Divider().background(.white.opacity(0.2))

                    // 🔹 History
                    if !patient.history.isEmpty {
                        Text("History:")
                            .foregroundColor(.red)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(patient.history, id: \.self) { entry in
                                Text(entry)
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    // 🔹 Karte
                    let addr = [patient.address ?? "", patient.city ?? ""].joined(separator: ", ")
                    AddressMapView(address: addr.isEmpty ? nil : addr, title: patient.name)
                }
                .padding()
            } else {
                ProgressView("Lade Patientendaten …")
                    .padding()
            }
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .task {
            await viewModel.loadPatient(id: patientId)
        }
        .navigationTitle("Profil")
        .sheet(isPresented: $showEmergencyContactSheet) {
            if let contact = viewModel.patient?.emergencyContact {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notfallkontakt")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text("Name:")
                            .bold()
                        Text("\(contact.name)")
                    }
                    
                    HStack {
                        Text("Telefon:")
                            .bold()
                        Text(contact.phone ?? "Keine Telefonnummer angegeben")
                    }
                    
                    HStack {
                        Text("E-Mail:")
                            .bold()
                        Text(contact.email ?? "Keine E-Mail-Adresse angegeben")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Adresse:")
                            .bold()
                        Text(contact.address ?? "Keine Adresse angegeben")
                    }
                    
                    Spacer()
                }
                .padding()
                .presentationDetents([.medium, .large])
            } else {
                VStack(spacing: 16) {
                    Text("Kein Notfallkontakt vorhanden.")
                        .font(.headline)
                        .padding(.top)
                    
                    Button {
                        viewModel.newEmergencyContact = EmergencyContact(
                            name: "",
                            relation: "",
                            phone: "",
                            email: "",
                            address: "",
                            age: nil
                        )
                        viewModel.showAddEmergencyContactSheet = true
                    } label: {
                        Label("Notfallkontakt hinzufügen", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                if viewModel.showAddEmergencyContactSheet {
                    EmergencyContactEditorView(viewModel: viewModel)
                }
            }
        }
    }
    
    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
    }
}

#Preview {
    PatientProfileView(patientId: "exampleId123")
        .preferredColorScheme(.dark)
}
