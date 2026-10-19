//
//  StatusCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Status mit Erstellt-, Fällig-Datum und Mitarbeiter
struct StatusCard: View {
    let order: Order
    let employeeName: String?

    var body: some View {
        SectionCard(title: tr("Status"), icon: "clock") {
            Label(order.state.displayName, systemImage: order.state.icon)
                .font(.title3.weight(.semibold))
                .foregroundColor(order.state.color)
            if let createdAt = order.createdAt {
                InfoRow(system: "clock", title: tr("Erstellt am"), value: createdAt.formattedDateTime)
            }
            if let dueDate = order.dueDate {
                InfoRow(system: "calendar", title: tr("Fällig am"), value: dueDate.formattedDateTime)
            }
            if let employeeName {
                InfoRow(system: "person", title: tr("Mitarbeiter"), value: employeeName)
            }
        }
    }
}
