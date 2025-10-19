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
        ZStack { CC.cardBackground() }
            .overlay(
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        AvatarView(initials: initials(from: patient.name), size: 48)
                        VStack(alignment: .leading) {
                            Text(patient.name).font(.headline).foregroundColor(.white)
                            Text("\(patient.age) Jahre • \(patient.city)").foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "mappin.and.ellipse").foregroundColor(.white.opacity(0.9))
                    }
                    Divider().background(.white.opacity(0.2))
                    Text("Medikamente:").foregroundColor(.red).bold()
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(patient.medications) { med in
                            Text("• " + med.name).foregroundColor(.white)
                        }
                    }
                }.padding()
            )
    }
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}
/*#Preview {
    PatientCardView()
}*/
