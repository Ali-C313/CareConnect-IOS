//
//  NewPrescriptionSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Neue Verordnung an einen freigegebenen Pflegedienst
struct NewPrescriptionSheet: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: PrescriptionsViewModel

    private var selectedPatient: Patient? { appState.patient(id: viewModel.formPatientId) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(tr("Patient"), selection: $viewModel.formPatientId) {
                        Text(tr("{0} wählen", tr("Patient"))).tag("")
                        ForEach(appState.patients) { patient in
                            Text(patient.name).tag(patient.id ?? "")
                        }
                    }
                    if let patient = selectedPatient {
                        let links = patient.linkedOrgs ?? []
                        if links.isEmpty {
                            Text(tr("{0} hat noch keinen Pflegedienst freigegeben. ", patient.name) +
                                 tr("Das geht in der App des Patienten unter Einstellungen → Freigaben."))
                                .font(.footnote)
                                .foregroundColor(.orange)
                        } else {
                            Picker(tr("Pflegedienst"), selection: $viewModel.formTargetId) {
                                Text(tr("{0} wählen", tr("Pflegedienst"))).tag("")
                                ForEach(links) { link in
                                    Text(link.orgName).tag(link.orgId)
                                }
                            }
                        }
                    }
                }

                Section {
                    TextField(tr("Was? (z.B. Verbandswechsel)"), text: $viewModel.formTitle)
                    TextField(tr("Wie oft? (z.B. 3x pro Woche)"), text: $viewModel.formFrequency)
                    DatePicker(tr("Ab wann"), selection: $viewModel.formStartDate, displayedComponents: .date)
                    TextField(tr("Hinweise für die Pflege"), text: $viewModel.formDetails, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let error = viewModel.formError {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle(tr("Neue Verordnung"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button(tr("Senden")) { send() }
                            .disabled(!viewModel.canSave)
                    }
                }
            }
        }
    }

    private func send() {
        Task {
            let saved = await viewModel.create(
                patient: selectedPatient,
                orgName: appState.membership?.orgName ?? "",
                myName: appState.currentEmployee?.name ?? ""
            )
            if saved { dismiss() }
        }
    }
}

#Preview {
    NewPrescriptionSheet(viewModel: PrescriptionsViewModel())
        .environment(AppStateViewModel())
}
