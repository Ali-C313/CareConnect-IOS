//
//  PatientCardView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation

struct PatientCardView: View {
    
    /// Patientendaten
    var patient: Patient
    
    /// UI-Inhalt
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AvatarView(initials: initials(from: patient.name), size: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                        .foregroundColor(CCDesign.textPrimary)
                    
                    Text(verbatim: "\(patient.age ?? 0) Jahre • \(patient.city)")
                        .font(.subheadline)
                        .foregroundColor(CCDesign.textSecondary)
                }
                Spacer()
            }
            
            Divider()
                .background(Color(.separator))
            
            if let meds = patient.medications, !meds.isEmpty {
                Text("Medikamente:")
                    .font(.subheadline.bold())
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(meds) { med in
                        Text("• \(med.name)")
                            .foregroundColor(CCDesign.textPrimary)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(CCDesign.card)
        .cornerRadius(12)
        .shadow(color: Color(.separator).opacity(0.4), radius: 2, x: 0, y: 1)
    }
    
    /// Initialen erzeugen
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}

#Preview {
    PatientCardView(patient: Patient(
        firstName: "Beate",
        lastName: "Keller",
        address: "Musterstraße 12, Köln",
        phone: "0123456789",
        birthDate: nil,
        notes: nil,
        city: "Berlin"
    ))
    .preferredColorScheme(.dark)
    .padding()
}