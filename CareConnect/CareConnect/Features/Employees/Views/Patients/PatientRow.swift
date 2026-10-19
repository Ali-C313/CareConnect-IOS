//
//  PatientRow.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Zeile in der Patientenliste
struct PatientRow: View {
    let patient: Patient

    var body: some View {
        SectionCard {
            HStack(spacing: 16) {
                AvatarView(initials: patient.initials, imageURL: patient.profileImageURL, size: 50)
                VStack(alignment: .leading, spacing: 2) {
                    Text(patient.name).font(.headline)
                    Text(patient.fullAddress.ifBlank(tr("Keine Adresse vorhanden")))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    PatientRow(patient: Patient(firstName: "Max", lastName: "Muster", address: "Hauptstr. 1"))
        .padding()
        .screenBackground()
}
