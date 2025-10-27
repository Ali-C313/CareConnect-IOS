//
//  PatientCardView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct PatientCardView: View {
    
    var patient: Patient
    
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
                
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.accentColor)
            }
            
            Divider()
                .background(Color(.separator))
            
            if !patient.medications.isEmpty {
                Text("Medikamente:")
                    .font(.subheadline.bold())
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(patient.medications) { med in
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
