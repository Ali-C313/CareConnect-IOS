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
                            
                            Text(patient.address)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(patient.city)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        
                        Image(systemName: "key.fill")
                            .foregroundColor(.white.opacity(0.9))
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
                    let addr = [patient.address, patient.city].joined(separator: ", ")
                    AddressMapView(address: addr.isEmpty ? nil : addr, title: patient.name)
                }
                .padding()
            } else {
                ProgressView("Lade Patientendaten …")
                    .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            await viewModel.loadPatient(id: patientId)
        }
        .navigationTitle("Profil")
    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}

#Preview {
    PatientProfileView(patientId: "exampleId123")
        .preferredColorScheme(.dark)
}
