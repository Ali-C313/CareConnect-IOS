//
//  OrderCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Karte in der Auftragsliste
struct OrderCard: View {
    @Environment(AppStateViewModel.self) private var appState
    let order: Order

    /// Name des zuständigen Mitarbeiters oder "Noch offen"
    private var employeeName: String {
        if let employee = appState.employee(id: order.assignedEmployeeId) { return employee.name }
        return order.assignedEmployeeId.isEmpty ? tr("Noch offen") : order.assignedEmployeeId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📋 \(order.displayPatientName)")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                StatusBadge(text: order.state.displayName, color: order.state.color)
            }
            if order.description.isBlank {
                Text(tr("Keine Beschreibung vorhanden."))
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                Text(order.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            if let dueDate = order.dueDate {
                SmallInfo(icon: "calendar", text: tr("Fällig: {0}", dueDate.formattedDateTime))
            }
            SmallInfo(icon: "person", text: employeeName)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCDesign.cardStyle())
    }
}
