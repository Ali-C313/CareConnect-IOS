//
//  AddEditAppointmentSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import FirebaseFirestore

/// Termin anlegen oder bearbeiten
struct AddEditAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var what: String
    @State private var address: String
    @State private var date: Date
    @State private var bringItems: [String]
    @State private var notes: String
    @State private var showCustomItemAlert = false
    @State private var customItem = ""

    /// nil = neuer Termin
    let appointment: AppointmentEntry?
    let onSave: (AppointmentEntry) -> Void

    init(appointment: AppointmentEntry?, onSave: @escaping (AppointmentEntry) -> Void) {
        self.appointment = appointment
        self.onSave = onSave
        _what = State(initialValue: appointment?.what ?? "")
        _address = State(initialValue: appointment?.address ?? "")
        _date = State(initialValue: appointment?.date.date ?? Date())
        _bringItems = State(initialValue: appointment?.bringItems ?? [])
        _notes = State(initialValue: appointment?.notes ?? "")
    }

    // Computed, damit die Liste beim Sprachwechsel neu übersetzt wird
    private var defaultBringItems: [String] {
        [tr("Ausweis"), tr("Krankenkassenkarte"), tr("Überweisung"), tr("Bericht")]
    }

    private var canSave: Bool { !what.isBlank && !address.isBlank }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(tr("Wo/Was (z. B. Arztbesuch)"), text: $what)
                    AddressSearchField(address: $address)
                    DatePicker(tr("Datum & Uhrzeit"), selection: $date)
                }

                Section(tr("Mitbringen (optional)")) {
                    Menu {
                        ForEach(defaultBringItems, id: \.self) { item in
                            Button(item) { addBringItem(item) }
                        }
                        Button(tr("+ Anderes hinzufügen...")) { showCustomItemAlert = true }
                    } label: {
                        Label(tr("Gegenstand hinzufügen"), systemImage: "bag.badge.plus")
                    }

                    ForEach(bringItems, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { bringItems.remove(atOffsets: $0) }
                }

                Section(tr("Bemerkungen (optional)")) {
                    TextField(tr("Bemerkungen"), text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle(appointment == nil ? tr("Termin hinzufügen") : tr("Termin bearbeiten"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Speichern")) { save() }
                        .disabled(!canSave)
                }
            }
            .alert(tr("Neuen Gegenstand hinzufügen"), isPresented: $showCustomItemAlert) {
                TextField(tr("Gegenstand"), text: $customItem)
                Button(tr("Hinzufügen")) {
                    addBringItem(customItem)
                    customItem = ""
                }
                Button(tr("Abbrechen"), role: .cancel) { customItem = "" }
            }
        }
    }

    private func addBringItem(_ item: String) {
        let trimmed = item.trimmed
        guard !trimmed.isEmpty, !bringItems.contains(trimmed) else { return }
        bringItems.append(trimmed)
    }

    private func save() {
        var entry = appointment ?? AppointmentEntry()
        entry.what = what.trimmed
        entry.address = address.trimmed
        entry.date = Timestamp(date: date)
        entry.bringItems = bringItems
        entry.notes = notes.trimmed
        onSave(entry)
        dismiss()
    }
}

#Preview {
    AddEditAppointmentSheet(appointment: nil) { _ in }
}
