//
//  AddEditAppointmentSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//

import SwiftUI
import Foundation

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
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Termin Details", systemImage: "calendar")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Wo/Was (z. B. Arztbesuch)", systemImage: "pencil")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("", text: $what)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card))
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Label("Adresse", systemImage: "mappin.and.ellipse")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("", text: $addressVM.queryFragment)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card))
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)

                                if !addressVM.suggestions.isEmpty {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(addressVM.suggestions, id: \.self) { suggestion in
                                                Button {
                                                    address = suggestion
                                                    addressVM.queryFragment = suggestion
                                                    addressVM.suggestions = []
                                                } label: {
                                                    Text(suggestion)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(2)
                                                        .padding(8)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .background(RoundedRectangle(cornerRadius: 8).fill(CCDesign.background.opacity(0.5)))
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 150)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Label("Datum & Uhrzeit", systemImage: "calendar.badge.clock")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(CCDesign.background)
                .listRowSeparator(.hidden)

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Mitbringen (optional)", systemImage: "bag")
                            .font(.headline)
                            .padding(.bottom, 4)

                        Picker(selection: $selectedItem) {
                            ForEach(defaultBringItems, id: \.self) { item in
                                Text(item).tag(item)
                            }
                            Text("+ Anderes hinzufügen...").tag("custom")
                        } label: {
                            Text("Gegenstände")
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedItem) { newValue in
                            if newValue == "custom" {
                                showAddCustomItem = true
                            } else if !bringItems.contains(newValue) {
                                bringItems.append(newValue)
                            }
                            selectedItem = ""
                        }

                        if !bringItems.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
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
                    .padding(.vertical, 8)
                }
                .listRowBackground(CCDesign.background)
                .listRowSeparator(.hidden)
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

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Notizen", systemImage: "note.text")
                            .font(.headline)
                            .padding(.bottom, 4)

                        TextField("Bemerkungen (optional)", text: $notes, axis: .vertical)
                            .lineLimit(2...4)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(CCDesign.card))
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(CCDesign.background)
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .background(CCDesign.background)
            .listStyle(.insetGrouped)
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
                    .tint(CCDesign.accent)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .tint(CCDesign.accent)
                }
            }
            .toolbarBackground(CCDesign.card, for: .navigationBar)
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
