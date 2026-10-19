//
//  AddMedicineSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Neues Medikament mit Dosierung und Einnahmezeit
struct AddMedicineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dosage = ""
    @State private var selectedTime: TimeOfDay = .morning

    let onSave: (_ name: String, _ dosage: String, _ timeOfDay: TimeOfDay) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(tr("Name"), text: $name)
                    TextField(tr("Dosierung"), text: $dosage)
                }
                Section(tr("Einnahmezeit")) {
                    Picker(tr("Einnahmezeit"), selection: $selectedTime) {
                        ForEach(TimeOfDay.allCases) { time in
                            Text(time.displayName).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(tr("Medikament hinzufügen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Speichern")) {
                        onSave(name, dosage, selectedTime)
                        dismiss()
                    }
                    .disabled(name.isBlank || dosage.isBlank)
                }
            }
        }
    }
}

#Preview {
    AddMedicineSheet { _, _, _ in }
}
