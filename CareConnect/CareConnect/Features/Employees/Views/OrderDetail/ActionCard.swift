//
//  ActionCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Aktionen passend zum Status: bearbeiten, annehmen, abschließen, löschen
struct ActionCard: View {
    let state: OrderState
    let isMine: Bool
    let assignedName: String?
    let onEdit: () -> Void
    let onAccept: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    // Angenommene Aufträge darf nur der zuständige Mitarbeiter ändern
    private var canModify: Bool { state == .offen || isMine }

    var body: some View {
        SectionCard(title: tr("Aktionen"), icon: "pencil") {
            if canModify && state != .erledigt {
                ActionButton(title: tr("Bearbeiten"), icon: "pencil", color: CCDesign.accent, action: onEdit)
            }
            switch state {
            case .offen:
                ActionButton(title: tr("Annehmen"), icon: "checkmark.circle.fill", color: .blue, action: onAccept)
            case .aktuell:
                if isMine {
                    ActionButton(title: tr("Abschließen"), icon: "checkmark.seal.fill", color: .green, action: onComplete)
                } else {
                    Text(tr("Angenommen von {0}", assignedName ?? tr("einem Kollegen")))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            case .erledigt:
                Label(tr("Auftrag abgeschlossen"), systemImage: "checkmark.seal.fill")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
            }
            if canModify {
                ActionButton(title: tr("Löschen"), icon: "trash", color: .red, action: onDelete)
            }
        }
    }
}

/// Breiter Button mit leicht eingefärbtem Hintergrund
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(color)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActionCard(state: .offen, isMine: false, assignedName: nil,
               onEdit: {}, onAccept: {}, onComplete: {}, onDelete: {})
        .padding()
        .screenBackground()
}
