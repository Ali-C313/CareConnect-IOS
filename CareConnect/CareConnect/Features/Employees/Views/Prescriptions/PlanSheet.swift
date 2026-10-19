//
//  PlanSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Verordnung übernehmen: ersten Einsatz und Wiederholung festlegen
struct PlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var start: Date
    @State private var weekdays: Set<Int> = []
    @State private var weeks = 4

    let prescription: Prescription
    let onConfirm: (_ start: Date, _ weekdays: Set<Int>, _ weeks: Int) -> Void

    init(prescription: Prescription, onConfirm: @escaping (Date, Set<Int>, Int) -> Void) {
        self.prescription = prescription
        self.onConfirm = onConfirm
        _start = State(initialValue: prescription.startDate?.date ?? Date())
    }

    private let weekdayLabels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    private var orderCount: Int {
        recurringDates(start: start, weekdays: weekdays, weeks: weeks).count
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(prescription.title + (prescription.frequency.isBlank ? "" : " · \(prescription.frequency)"))
                        .foregroundColor(.secondary)
                    DatePicker(tr("Erster Einsatz"), selection: $start)
                }

                Section(tr("Wiederholen an (leer = nur einmal)")) {
                    HStack(spacing: 4) {
                        ForEach(1...7, id: \.self) { day in
                            dayButton(day)
                        }
                    }
                    if !weekdays.isEmpty {
                        Stepper(tr("Für") + " " + tr("{0} Wochen", weeks), value: $weeks, in: 1...12)
                        Text(tr("{0} Aufträge werden angelegt.", orderCount))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(tr("Einsätze planen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Übernehmen")) {
                        onConfirm(start, weekdays, weeks)
                        dismiss()
                    }
                }
            }
        }
    }

    private func dayButton(_ day: Int) -> some View {
        let selected = weekdays.contains(day)
        return Button {
            if selected { weekdays.remove(day) } else { weekdays.insert(day) }
        } label: {
            Text(tr(weekdayLabels[day - 1]))
                .font(.footnote.bold())
                .frame(maxWidth: .infinity, minHeight: 36)
                .foregroundColor(selected ? .white : CCDesign.textPrimary)
                .background(selected ? CCDesign.accent : CCDesign.field, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlanSheet(prescription: Prescription(title: "Verbandswechsel", frequency: "3x pro Woche")) { _, _, _ in }
}
