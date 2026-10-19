//
//  PatientMedicineView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Medikamente sortiert nach Morgens, Mittags und Abends
struct PatientMedicineView: View {
    @State private var viewModel = MedicineViewModel()
    @State private var showAddSheet = false

    var body: some View {
        List {
            ForEach(TimeOfDay.allCases) { time in
                Section(time.displayName) {
                    let list = viewModel.entries(for: time)
                    if list.isEmpty {
                        Text(tr("Keine Medikamente eingetragen.")).foregroundColor(.secondary)
                    }
                    ForEach(list) { medicine in
                        Label("\(medicine.name) – \(medicine.dosage)", systemImage: "pills.fill")
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteMedicine(medicine)
                                } label: {
                                    Label(tr("Löschen"), systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .screenBackground()
        .navigationTitle(tr("Medikamente"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel(tr("Medikament hinzufügen"))
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddMedicineSheet { name, dosage, time in
                viewModel.addMedicine(name: name, dosage: dosage, timeOfDay: time)
            }
            .presentationDetents([.medium])
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
        .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
    }
}

#Preview {
    NavigationStack { PatientMedicineView() }
}
