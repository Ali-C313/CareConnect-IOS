//
//  AddEditAppointmentSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import SwiftUI

struct AddEditAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AppointmentsViewModel
    @StateObject private var addressVM = AddressSearchViewModel()

    @State private var what: String = ""
    @State private var address: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""

    @State private var bringItems: [String] = []
    @State private var selectedItem: String = ""
    @State private var showAddCustomItem: Bool = false
    @State private var customItem: String = ""

    private let defaultBringItems = ["Ausweis", "Krankenkassenkarte", "Überweisung", "Bericht"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Termin Details") {
                    TextField("Wo/Was (z. B. Arztbesuch)", text: $what)
                    VStack(alignment: .leading) {
                        TextField("Adresse", text: $addressVM.queryFragment)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)

                        if !addressVM.suggestions.isEmpty {
                            List(addressVM.suggestions, id: \.self) { suggestion in
                                Button {
                                    address = suggestion
                                    addressVM.queryFragment = suggestion
                                    addressVM.suggestions = []
                                } label: {
                                    Text(suggestion)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                }
                            }
                            .frame(maxHeight: 150)
                        }
                    }

                    DatePicker("Datum & Uhrzeit", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                Section("Mitbringen (optional)") {
                    Picker("Gegenstände", selection: $selectedItem) {
                        ForEach(defaultBringItems, id: \.self) { item in
                            Text(item).tag(item)
                        }
                        Text("+ Anderes hinzufügen...").tag("custom")
                    }
                    .onChange(of: selectedItem) { newValue in
                        if newValue == "custom" {
                            showAddCustomItem = true
                        } else if !bringItems.contains(newValue) {
                            bringItems.append(newValue)
                        }
                    }

                    if !bringItems.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(bringItems, id: \.self) { item in
                                    Text(item)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.15))
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            withAnimation {
                                                bringItems.removeAll { $0 == item }
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.top, 4)
                        Text("(Zum Entfernen tippen)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .alert("Neuen Gegenstand hinzufügen", isPresented: $showAddCustomItem) {
                    TextField("Gegenstand", text: $customItem)
                    Button("Hinzufügen") {
                        if !customItem.trimmingCharacters(in: .whitespaces).isEmpty {
                            bringItems.append(customItem)
                        }
                        customItem = ""
                    }
                    Button("Abbrechen", role: .cancel) { customItem = "" }
                }

                Section("Notizen") {
                    TextField("Bemerkungen (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Termin hinzufügen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let appointment = AppointmentEntry(
                            what: what,
                            address: address,
                            date: date,
                            bringItems: bringItems,
                            notes: notes.isEmpty ? nil : notes
                        )

                        if let editing = viewModel.editingAppointment {
                            let updated = AppointmentEntry(
                                id: editing.id,
                                what: what,
                                address: address,
                                date: date,
                                bringItems: bringItems,
                                notes: notes.isEmpty ? nil : notes
                            )
                            viewModel.updateAppointment(updated)
                        } else {
                            viewModel.addAppointment(appointment)
                        }

                        dismiss()
                    }
                    .disabled(what.isEmpty || address.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .onAppear {
                if let editing = viewModel.editingAppointment {
                    what = editing.what
                    address = editing.address
                    date = editing.date
                    bringItems = editing.bringItems
                    notes = editing.notes ?? ""
                    addressVM.queryFragment = editing.address
                }
            }
        }
    }
}

#Preview {
    AddEditAppointmentSheet(viewModel: AppointmentsViewModel())
}
