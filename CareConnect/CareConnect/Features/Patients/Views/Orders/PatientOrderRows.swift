//
//  PatientOrderRows.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Hervorgehobene Karte für den Einsatz, der gerade läuft
struct ActiveOrderCard: View {
    let order: Order
    let employeeName: String?

    private var title: String {
        guard let employeeName, !employeeName.isBlank else { return OrderState.aktuell.patientLabel }
        return tr("{0} ist unterwegs zu dir", employeeName)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(CCDesign.accent, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(tr("Aktiver Auftrag")).font(.caption)
                Text(title).font(.headline)
                Text(order.description.ifBlank(order.displayTitle))
                    .font(.subheadline)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(CCDesign.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 20))
    }
}

/// Mehrere Aufträge in einer Karte, mit Trennlinien
struct PatientOrderGroup: View {
    let orders: [Order]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(orders) { order in
                NavigationLink {
                    PatientOrderDetailView(orderId: order.id)
                } label: {
                    PatientOrderRow(order: order)
                }
                .buttonStyle(.plain)

                if order.id != orders.last?.id {
                    Divider().padding(.leading, 68)
                }
            }
        }
        .background(CCDesign.cardStyle())
    }
}

/// Zeile mit Icon, Beschreibung, Datum und Status
struct PatientOrderRow: View {
    let order: Order

    private var icon: String {
        order.state == .aktuell ? "car.fill" : order.state.icon
    }

    private var date: String? {
        let timestamp = order.state == .erledigt
            ? order.report?.completedAt ?? order.dueDate ?? order.createdAt
            : order.dueDate ?? order.createdAt
        return timestamp?.formattedDateTime
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(order.state.color)
                .frame(width: 40, height: 40)
                .background(order.state.color.opacity(0.15), in: Circle())
            VStack(alignment: .leading) {
                Text(order.description.ifBlank(order.displayTitle))
                    .fontWeight(.medium)
                    .lineLimit(1)
                if let date {
                    Text(date)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            StatusBadge(text: order.state.patientLabel, color: order.state.color)
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        ActiveOrderCard(order: Order(state: .aktuell, description: "Verbandswechsel"), employeeName: "Mia")
        PatientOrderGroup(orders: [Order(description: "Blutdruck messen")])
    }
    .padding()
    .screenBackground()
}
