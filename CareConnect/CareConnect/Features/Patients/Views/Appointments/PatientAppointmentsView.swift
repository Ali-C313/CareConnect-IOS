//
//  PatientAppointmentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Termine des Patienten
struct PatientAppointmentsView: View {
    @State private var viewModel = AppointmentsViewModel()
    @State private var showAddSheet = false
    @State private var editingAppointment: AppointmentEntry?
    @State private var selectedAppointment: AppointmentEntry?

    var body: some View {
        Group {
            if viewModel.appointments.isEmpty {
                ContentUnavailableView(
                    tr("Keine Termine"),
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text(tr("Füge mit dem + Button oben rechts einen Termin hinzu."))
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.sortedAppointments) { appointment in
                            AppointmentRow(
                                appointment: appointment,
                                onTap: { selectedAppointment = appointment },
                                onEdit: { editingAppointment = appointment },
                                onDelete: { viewModel.delete(appointment) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Termine"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel(tr("Termin hinzufügen"))
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditAppointmentSheet(appointment: nil, onSave: viewModel.save)
        }
        .sheet(item: $editingAppointment) { appointment in
            AddEditAppointmentSheet(appointment: appointment, onSave: viewModel.save)
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailsView(appointment: appointment)
                .presentationDetents([.medium])
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
        .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
    }
}

/// Zeile mit Bearbeiten und Löschen
struct AppointmentRow: View {
    let appointment: AppointmentEntry
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        SectionCard {
            HStack {
                Button(action: onTap) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar").foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(appointment.what).font(.headline)
                            Text(appointment.date.formattedDateTime)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                Button(action: onEdit) {
                    Image(systemName: "pencil").foregroundColor(.blue).padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tr("Bearbeiten"))

                Button(action: onDelete) {
                    Image(systemName: "trash").foregroundColor(.red).padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tr("Löschen"))
            }
        }
    }
}

/// Details zu einem Termin
struct AppointmentDetailsView: View {
    @Environment(\.openURL) private var openURL
    let appointment: AppointmentEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(appointment.what).font(.title2.bold())
                InfoRow(system: "calendar", title: tr("Datum"), value: appointment.date.formattedDateTime)
                if !appointment.address.isBlank {
                    InfoButtonRow(system: "mappin", title: tr("Adresse"), value: appointment.address,
                                  buttonTitle: tr("In Karten öffnen"), buttonIcon: "map") {
                        if let url = Links.mapsSearch(appointment.address) { openURL(url) }
                    }
                }
                if let items = appointment.bringItems, !items.isEmpty {
                    InfoRow(system: "bag", title: tr("Mitbringen"), value: items.joined(separator: ", "))
                }
                if let notes = appointment.notes, !notes.isBlank {
                    InfoRow(system: "note.text", title: tr("Notizen"), value: notes)
                } else {
                    Text(tr("Keine weiteren Informationen.")).foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack { PatientAppointmentsView() }
}
