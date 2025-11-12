//
//  ActionCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 12.11.25.
//

import SwiftUI

struct ActionCard: View {
    var onEdit: (() -> Void)?
    var onAccept: (() -> Void)?
    var onComplete: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Aktionen")
                    .font(.headline)
            } icon: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 10) {
                Button {
                    onEdit?()
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(10)
                }

                Button {
                    onAccept?()
                } label: {
                    Label("Annehmen", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }

                Button {
                    onComplete?()
                } label: {
                    Label("Abschließen", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                }

                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Löschen", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ActionCard(
        onEdit: { print("Bearbeiten") },
        onAccept: { print("Annehmen") },
        onComplete: { print("Abschließen") },
        onDelete: { print("Löschen") }
    )
}
