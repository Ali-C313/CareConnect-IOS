//
//  PrescriptionCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Verordnung mit den passenden Buttons je nach Status
struct PrescriptionCard: View {
    let prescription: Prescription
    let incoming: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onComplete: () -> Void
    let onWithdraw: () -> Void

    var body: some View {
        SectionCard {
            HStack {
                Text(prescription.title).font(.headline)
                Spacer()
                StatusBadge(text: prescription.status.displayName, color: prescription.status.color)
            }
            infoLine(icon: "person", text: prescription.patientName)
            infoLine(icon: "building.2",
                     text: incoming ? tr("von {0}", prescription.fromOrgName) : tr("an {0}", prescription.toOrgName))
            if !prescription.frequency.isBlank {
                infoLine(icon: "repeat", text: prescription.frequency)
            }
            if let startDate = prescription.startDate {
                Text(tr("ab {0}", startDate.formattedDate) +
                     (prescription.createdByName.isBlank ? "" : " · \(prescription.createdByName)"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if !prescription.details.isBlank {
                Text(prescription.details).font(.subheadline)
            }
            buttons
        }
    }

    @ViewBuilder
    private var buttons: some View {
        if incoming && prescription.status == .offen {
            HStack {
                Button(tr("Als Auftrag übernehmen"), action: onAccept)
                    .buttonStyle(.borderedProminent)
                Button(tr("Ablehnen"), action: onDecline)
                    .buttonStyle(.bordered)
            }
        } else if incoming && prescription.status == .angenommen {
            Button(action: onComplete) {
                Text(tr("Als erledigt markieren")).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        } else if !incoming && prescription.status == .offen {
            Button(role: .destructive, action: onWithdraw) {
                Text(tr("Zurückziehen")).frame(maxWidth: .infinity)
            }
        }
    }

    private func infoLine(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(CCDesign.accent)
            Text(text).font(.subheadline)
        }
    }
}

#Preview {
    PrescriptionCard(
        prescription: Prescription(fromOrgName: "Praxis Dr. Weber", patientName: "Maria Schmidt",
                                   title: "Verbandswechsel", frequency: "3x pro Woche"),
        incoming: true, onAccept: {}, onDecline: {}, onComplete: {}, onWithdraw: {}
    )
    .padding()
    .screenBackground()
}
