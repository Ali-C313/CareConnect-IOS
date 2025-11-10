//
//  InfoButtonRow.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import SwiftUI
import Foundation

struct InfoButtonRow: View {
    let system: String
    let title: String
    let value: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: system)
                    .foregroundColor(.accentColor)
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
                    Label(buttonTitle, systemImage: "arrow.right.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            Divider()
                .background(Color.primary.opacity(0.1))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    InfoButtonRow(
        system: "stethoscope",
        title: "Hausarzt",
        value: "Dr. Müller",
        buttonTitle: "Mehr",
        action: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
}