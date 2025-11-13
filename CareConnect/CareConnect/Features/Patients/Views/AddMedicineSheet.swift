//
//  AddMedicineSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import SwiftUI
import Foundation

struct AddMedicineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MedicineViewModel
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var selectedTime: TimeOfDay = .morning

    var body: some View {
        NavigationStack {
            Form {
                Section("Medikament") {
                    TextField("Name", text: $name)
                    TextField("Dosierung", text: $dosage)
                }

                Section("Einnahmezeit") {
                    Picker("Tageszeit", selection: $selectedTime) {
                        ForEach(TimeOfDay.allCases, id: \.self) { time in
                            Text(time.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Medikament hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let newMed = MedicineEntry(name: name, dosage: dosage, timeOfDay: selectedTime)
                        Task {
                            await viewModel.addMedicine(newMed)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddMedicineSheet(viewModel: MedicineViewModel(patientId: "preview-demo-patient"))
}
