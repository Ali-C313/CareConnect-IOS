//
//  PatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct PatientProfileView: View {
    var patient: Patient

    var body: some View {
        ZStack { GradientBackground() }
            .overlay(content)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    AvatarView(initials: initials(from: patient.name), size: 64)
                    VStack(alignment: .leading) {
                        Text(patient.name).font(.title2).bold().foregroundColor(.white)
                        Text("\(patient.age) Jahre").foregroundColor(.white.opacity(0.9))
                        if let address = patient.address { Text(address).foregroundColor(.white.opacity(0.9)) }
                        Text(patient.city).foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "key.fill").foregroundColor(.white.opacity(0.9))
                }
                Divider().background(.white.opacity(0.2))

                Text("Medikamente:").foregroundColor(.red).bold()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(patient.medications) { med in
                        Text("• " + med.name).foregroundColor(.white)
                    }
                }
                Divider().background(.white.opacity(0.2))

                if !patient.history.isEmpty {
                    Text("History:").foregroundColor(.red).bold()
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(patient.history, id: \.self) { entry in
                            Text(entry).foregroundColor(.white)
                        }
                    }
                }

                MapPlaceholderView()
            }
            .padding()
        }
    }
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}
#Preview {
    let meds = [Medication(name: "Herztabletten"), Medication(name: "Knochen Tabletten")]
    let p = Patient(name: "Berta Landmann", age: 88, city: "Berlin Kreuzberg", address: "Legiendamm 16", medications: meds)
    return PatientProfileView(patient: p)
}
