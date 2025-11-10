//
//  InfoRow.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import SwiftUI
import Foundation

struct InfoRow: View {
    let system: String
    let title: String
    let value: String

    var body: some View {
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
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    InfoRow(system: "person.fill", title: "Name", value: "Ali Chehab")
        .previewLayout(.sizeThatFits)
        .padding()
}