//
//  PrescriptionsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Verordnungen zwischen Praxis/Klinik und Pflegedienst
struct PrescriptionsView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var viewModel = PrescriptionsViewModel()
    @State private var showNewSheet = false
    @State private var planTarget: Prescription?
    @State private var didSetDirection = false

    // Nur Praxis und Klinik dürfen verordnen
    private var canPrescribe: Bool { appState.membership?.orgType != .pflegedienst }

    private var prescriptions: [Prescription] {
        viewModel.filtered(appState.prescriptions, orgId: appState.orgId)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker(tr("Richtung"), selection: $viewModel.direction) {
                ForEach(PrescriptionDirection.allCases) { direction in
                    Text(direction.displayName).tag(direction)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if prescriptions.isEmpty {
                ContentUnavailableView(
                    tr("Keine Verordnungen"),
                    systemImage: "list.clipboard",
                    description: Text(viewModel.direction == .incoming
                        ? tr("Hier landen Verordnungen von Praxen und Kliniken für eure Patienten.")
                        : tr("Verordnungen gehen an den Pflegedienst, den der Patient freigegeben hat."))
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(prescriptions) { prescription in
                            PrescriptionCard(
                                prescription: prescription,
                                incoming: viewModel.direction == .incoming,
                                onAccept: { planTarget = prescription },
                                onDecline: { viewModel.decline(prescription) },
                                onComplete: { viewModel.complete(prescription) },
                                onWithdraw: { viewModel.withdraw(prescription) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .screenBackground()
        .navigationTitle(tr("Verordnungen"))
        .toolbar {
            if canPrescribe {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.resetForm()
                        showNewSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel(tr("Neue Verordnung"))
                }
            }
        }
        .sheet(isPresented: $showNewSheet) {
            NewPrescriptionSheet(viewModel: viewModel)
        }
        .sheet(item: $planTarget) { prescription in
            PlanSheet(prescription: prescription) { start, weekdays, weeks in
                viewModel.accept(prescription, start: start, weekdays: weekdays, weeks: weeks)
            }
        }
        .messageAlert(tr("Verordnung"), message: $viewModel.message)
        .onAppear {
            // Praxis sieht zuerst, was sie verschickt hat
            if canPrescribe && !didSetDirection { viewModel.direction = .outgoing }
            didSetDirection = true
        }
    }
}

#Preview {
    NavigationStack { PrescriptionsView() }
        .environment(AppStateViewModel())
}
