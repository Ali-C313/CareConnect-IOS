//
//  NewOrderSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Sheet zum Erstellen oder Bearbeiten eines Auftrags
struct NewOrderSheet: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewOrderViewModel

    /// - Parameter existingOrder: nil = neuer Auftrag
    init(existingOrder: Order? = nil) {
        _viewModel = State(initialValue: NewOrderViewModel(existingOrder: existingOrder))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(tr("Patient")) {
                    Picker(tr("Patient"), selection: $viewModel.patientId) {
                        Text(tr("Patient wählen")).tag("")
                        ForEach(appState.patients) { patient in
                            Text(patient.name).tag(patient.id ?? "")
                        }
                    }
                }

                Section(tr("Beschreibung")) {
                    TextField(tr("Beschreibung des Auftrags"), text: $viewModel.descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(tr("Zeitpunkt")) {
                    DatePicker(tr("Ausführungszeit"), selection: $viewModel.dueDate,
                               displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle(viewModel.isEditing ? tr("Auftrag bearbeiten") : tr("Neuer Auftrag"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button(tr("Speichern")) {
                            Task {
                                let saved = await viewModel.save(
                                    patient: appState.patient(id: viewModel.patientId),
                                    creatorId: appState.userId
                                )
                                if saved { dismiss() }
                            }
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
            }
            .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
        }
    }
}

#Preview {
    NewOrderSheet()
        .environment(AppStateViewModel())
}
