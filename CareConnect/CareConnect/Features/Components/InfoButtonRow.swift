//
//  InfoButtonRow.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Wie InfoRow, aber mit Button rechts (z. B. Anrufen, E-Mail, Karte)
struct InfoButtonRow: View {
    let system: String
    let title: String
    let value: String
    let buttonTitle: String
    var buttonIcon: String = "arrow.right.circle.fill"
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: system)
                .foregroundColor(CCDesign.accent)
                .font(.headline)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
            Button(action: action) {
                Label(buttonTitle, systemImage: buttonIcon)
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .foregroundColor(CCDesign.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    InfoButtonRow(system: "phone.fill", title: "Telefon", value: "0176 1234567", buttonTitle: "Anrufen") {}
        .padding()
}
