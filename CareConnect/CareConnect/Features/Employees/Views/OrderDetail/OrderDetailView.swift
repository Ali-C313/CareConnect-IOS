//
//  OrderDetailView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

struct OrderDetailView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = OrderDetailViewModel()
    @State private var showCompleteSheet = false
    @State private var showDeleteDialog = false
    @State private var showEditSheet = false

    let orderId: String

    private var order: Order? { appState.order(id: orderId) }
    private var patient: Patient? { appState.patient(id: order?.patientId) }
    private var assignedEmployee: Employee? { appState.employee(id: order?.assignedEmployeeId) }

    var body: some View {
        ZStack {
            if let order {
                ScrollView {
                    VStack(spacing: 16) {
                        HeaderCard(order: order, patient: patient)
                        StatusCard(order: order, employeeName: assignedEmployee?.name)
                        if order.state == .aktuell {
                            LiveMapCard(
                                employeeCoordinate: viewModel.employeeCoordinate,
                                patientCoordinate: viewModel.patientCoordinate,
                                route: viewModel.route
                            )
                        }
                        if let report = order.report {
                            ReportCard(report: report)
                        }
                        if let patient {
                            PatientCard(patient: patient)
                        }
                        ActionCard(
                            state: order.state,
                            isMine: !order.assignedEmployeeId.isEmpty && order.assignedEmployeeId == appState.userId,
                            assignedName: assignedEmployee?.name,
                            onEdit: { showEditSheet = true },
                            onAccept: { viewModel.accept(order) },
                            onComplete: { showCompleteSheet = true },
                            onDelete: { showDeleteDialog = true }
                        )
                    }
                    .padding()
                }
                .onAppear {
                    startLive(for: order)
                    viewModel.loadPatientCoordinate(address: patient?.fullAddress ?? "")
                }
                .onChange(of: order) { _, newOrder in startLive(for: newOrder) }
                .onChange(of: patient?.fullAddress) { _, newAddress in
                    viewModel.loadPatientCoordinate(address: newAddress ?? "")
                }
            } else {
                ContentUnavailableView(
                    tr("Auftrag nicht gefunden"),
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(tr("Der Auftrag wurde gelöscht oder ist nicht mehr verfügbar."))
                )
            }

            // Lade-Overlay während einer Aktion
            if viewModel.isProcessing {
                Color.black.opacity(0.35).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .screenBackground()
        .navigationTitle(tr("Auftragsdetails"))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { viewModel.stopListening() }
        .sheet(isPresented: $showCompleteSheet) {
            CompletionSheet(patientName: patient?.name ?? order?.patientName ?? "") { note, signature, signedBy in
                if let order {
                    viewModel.complete(order, note: note, signature: signature, signedBy: signedBy,
                                       myName: appState.currentEmployee?.name ?? "")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NewOrderSheet(existingOrder: order)
        }
        .alert(tr("Auftrag löschen?"), isPresented: $showDeleteDialog) {
            Button(tr("Löschen"), role: .destructive) {
                if let order { viewModel.delete(order) { dismiss() } }
            }
            Button(tr("Abbrechen"), role: .cancel) {}
        } message: {
            Text(tr("Der Auftrag wird dauerhaft gelöscht."))
        }
        .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
    }

    /// Live-Standort nur bei aktuellen Aufträgen
    private func startLive(for order: Order) {
        viewModel.observeLocation(of: order.state == .aktuell ? order.assignedEmployeeId : nil)
    }
}

#Preview {
    NavigationStack { OrderDetailView(orderId: "1") }
        .environment(AppStateViewModel())
}
