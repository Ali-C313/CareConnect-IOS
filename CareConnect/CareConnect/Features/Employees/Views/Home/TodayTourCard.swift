//
//  TodayTourCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Einsätze für heute in zeitlicher Reihenfolge
struct TodayTourCard: View {
    @Environment(AppStateViewModel.self) private var appState
    let stops: [Order]
    let onRouteTap: () -> Void

    var body: some View {
        SectionCard(title: tr("Heute für dich"), icon: "point.topleft.down.to.point.bottomright.curvepath") {
            if stops.isEmpty {
                Text(tr("Heute stehen keine Einsätze an.")).foregroundColor(.secondary)
            }
            ForEach(stops) { order in
                NavigationLink {
                    OrderDetailView(orderId: order.id)
                } label: {
                    row(order)
                }
                .buttonStyle(.plain)
            }
            if stops.contains(where: { !(appState.patient(id: $0.patientId)?.fullAddress ?? "").isBlank }) {
                Button(action: onRouteTap) {
                    Label(tr("Tour in Google Maps"), systemImage: "map")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func row(_ order: Order) -> some View {
        HStack(spacing: 12) {
            Text(order.dueDate?.date.formattedTime ?? "--:--")
                .fontWeight(.bold)
                .foregroundColor(CCDesign.accent)
            VStack(alignment: .leading) {
                Text((order.patientName ?? "").ifBlank(tr("Patient"))).fontWeight(.semibold)
                Text((appState.patient(id: order.patientId)?.fullAddress ?? "").ifBlank(order.description))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(order.state.displayName)
                .font(.caption)
                .foregroundColor(order.state.color)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
