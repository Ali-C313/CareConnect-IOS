//
//  HeaderCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Patient, Beschreibung und Bemerkungen
struct HeaderCard: View {
    let order: Order
    let patient: Patient?

    var body: some View {
        SectionCard {
            Text(tr("Patientenauftrag"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(order.displayPatientName)
                .font(.title2.weight(.semibold))
            if !order.description.isBlank {
                Text(order.description).foregroundColor(.secondary)
            }
            if let birthDate = patient?.birthDate {
                Text(tr("Geboren: {0} • {1} Jahre", birthDate.formattedDate, birthDate.ageYears))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if !order.notesText.isEmpty {
                InfoRow(system: "note.text", title: tr("Bemerkungen"), value: order.notesText)
            }
        }
    }
}
