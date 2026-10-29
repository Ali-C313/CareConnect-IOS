//
//  HomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Home-Screen für Mitarbeiter mit Status, Statistik, Tour und Team
struct HomeView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.openURL) private var openURL

    /// Heutige Einsätze: eigene und noch freie, nach Uhrzeit
    private var todayTour: [Order] {
        appState.orders
            .filter { order in
                guard let due = order.dueDate?.date, Calendar.current.isDateInToday(due), order.state != .erledigt else {
                    return false
                }
                return order.assignedEmployeeId == appState.userId
                    || (order.state == .offen && order.assignedEmployeeId.isEmpty)
            }
            .sorted { ($0.dueDate?.date ?? .distantFuture) < ($1.dueDate?.date ?? .distantFuture) }
    }

    private func count(_ state: OrderState) -> Int {
        appState.orders.filter { $0.state == state }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StatusHeaderView()
                Text(tr("Tippe auf den Status, um ihn zu ändern"))
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    StatTile(value: count(.offen), label: tr("Offen"), icon: OrderState.offen.icon, color: .orange)
                    StatTile(value: count(.aktuell), label: tr("Aktuell"), icon: OrderState.aktuell.icon, color: .blue)
                    StatTile(value: count(.erledigt), label: tr("Erledigt"), icon: OrderState.erledigt.icon, color: .green)
                }

                TodayTourCard(stops: todayTour) {
                    let addresses = todayTour.compactMap { appState.patient(id: $0.patientId)?.fullAddress }
                        .filter { !$0.isBlank }
                    if let url = Links.tour(addresses) { openURL(url) }
                }

                Text(tr("👥 Mitarbeiter"))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                ForEach(appState.employees) { employee in
                    NavigationLink {
                        EmployeeProfileView(employeeId: employee.id ?? "")
                    } label: {
                        EmployeeRow(employee: employee)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .screenBackground()
        .navigationTitle(tr("Home"))
    }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(AppStateViewModel())
}
