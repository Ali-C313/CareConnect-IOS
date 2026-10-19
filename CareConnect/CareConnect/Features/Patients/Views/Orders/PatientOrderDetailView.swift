//
//  PatientOrderDetailView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Auftrag aus Sicht des Patienten mit Live-Karte, Status und Leistungsnachweis
struct PatientOrderDetailView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = PatientOrderDetailViewModel()

    let orderId: String

    private var order: Order? { appState.order(id: orderId) }

    var body: some View {
        Group {
            if let order {
                ScrollView {
                    VStack(spacing: 16) {
                        headerCard(order)
                        if order.state == .aktuell {
                            LiveSection(
                                showLiveLocation: appState.showLiveLocation,
                                employeeCoordinate: viewModel.employeeCoordinate,
                                homeCoordinate: viewModel.homeCoordinate,
                                route: viewModel.route,
                                onAllow: { appState.showLiveLocation = true },
                                onDeny: { appState.showLiveLocation = false }
                            )
                        }
                        StatusTimeline(order: order)
                        if !order.assignedEmployeeId.isEmpty {
                            EmployeeSection(employee: appState.employee(id: order.assignedEmployeeId))
                        }
                        if let report = order.report {
                            PatientReportCard(report: report)
                        }
                    }
                    .padding()
                }
                .onAppear { viewModel.loadHomeCoordinate(address: appState.currentPatient?.fullAddress ?? "") }
                .onChange(of: appState.currentPatient?.fullAddress) { _, newAddress in
                    viewModel.loadHomeCoordinate(address: newAddress ?? "")
                }
            } else {
                ContentUnavailableView(
                    tr("Auftrag nicht gefunden"),
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(tr("Dieser Auftrag existiert nicht mehr."))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Auftragsdetails"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: updateLive)
        .onChange(of: order) { _, _ in updateLive() }
        .onChange(of: appState.showLiveLocation) { _, _ in updateLive() }
        .onDisappear { viewModel.stopListening() }
    }

    private func headerCard(_ order: Order) -> some View {
        SectionCard {
            HStack {
                Text(order.description.ifBlank(order.displayTitle))
                    .font(.title3.weight(.semibold))
                Spacer()
                StatusBadge(text: order.state.patientLabel, color: order.state.color)
            }
            if let date = order.dueDate ?? order.createdAt {
                InfoRow(system: "calendar", title: tr("Datum"), value: date.formattedDateTime)
            }
        }
    }

    /// Standort nur, solange der Auftrag läuft und der Patient zugestimmt hat
    private func updateLive() {
        let isLive = appState.showLiveLocation == true && order?.state == .aktuell
        viewModel.observeLocation(of: isLive ? order?.assignedEmployeeId : nil)
    }
}

#Preview {
    NavigationStack { PatientOrderDetailView(orderId: "1") }
        .environment(AppStateViewModel())
}
