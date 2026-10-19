//
//  PatientOrdersView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eigene Aufträge: aktiver Einsatz, offen und erledigt
struct PatientOrdersView: View {
    @Environment(AppStateViewModel.self) private var appState

    private var activeOrder: Order? { appState.myOrders.first { $0.state == .aktuell } }

    // Nächster Termin zuerst
    private var openOrders: [Order] {
        appState.myOrders
            .filter { $0.state == .offen }
            .sorted { dueDate($0) < dueDate($1) }
    }

    // Zuletzt erledigt zuerst
    private var doneOrders: [Order] {
        appState.myOrders
            .filter { $0.state == .erledigt }
            .sorted { doneDate($0) > doneDate($1) }
    }

    var body: some View {
        Group {
            if appState.myOrders.isEmpty {
                ContentUnavailableView(
                    tr("Noch keine Aufträge"),
                    systemImage: "tray",
                    description: Text(tr("Hier erscheinen deine Aufträge, sobald einer angelegt wurde."))
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if let activeOrder {
                            NavigationLink {
                                PatientOrderDetailView(orderId: activeOrder.id)
                            } label: {
                                ActiveOrderCard(order: activeOrder,
                                                employeeName: appState.employee(id: activeOrder.assignedEmployeeId)?.name)
                            }
                            .buttonStyle(.plain)
                        }

                        orderSection(title: tr("Offen"), orders: openOrders, emptyText: tr("Keine offenen Aufträge."))
                        orderSection(title: tr("Erledigt"), orders: doneOrders, emptyText: tr("Keine erledigten Aufträge."))
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Meine Aufträge"))
    }

    @ViewBuilder
    private func orderSection(title: String, orders: [Order], emptyText: String) -> some View {
        Text("\(title) (\(orders.count))")
            .font(.headline)
            .padding(.top, 8)
        if orders.isEmpty {
            Text(emptyText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        } else {
            PatientOrderGroup(orders: orders)
        }
    }

    private func dueDate(_ order: Order) -> Date {
        (order.dueDate ?? order.createdAt)?.date ?? .distantFuture
    }

    private func doneDate(_ order: Order) -> Date {
        (order.report?.completedAt ?? order.dueDate ?? order.createdAt)?.date ?? .distantPast
    }
}

#Preview {
    NavigationStack { PatientOrdersView() }
        .environment(AppStateViewModel())
}
