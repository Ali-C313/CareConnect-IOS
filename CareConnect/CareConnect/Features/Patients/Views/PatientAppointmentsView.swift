//
//  PatientAppointmentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation

struct PatientAppointmentsView: View {
    
    @State private var showAddSheet = false
    @StateObject private var appointmentsVM = AppointmentsViewModel()
    @State private var selectedAppointment: AppointmentEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(appointmentsVM.appointments, id: \.stableId) { appointment in
                    Button {
                        selectedAppointment = appointment
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.blue)
                                Text(appointment.what)
                                    .font(.headline)
                            }
                            Text(formattedDate(appointment.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            appointmentsVM.deleteAppointment(appointment)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }

                        Button {
                            appointmentsVM.editingAppointment = appointment
                            showAddSheet = true
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Termine")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appointmentsVM.editingAppointment = nil
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .onAppear {
                appointmentsVM.fetchAppointments()
            }
            .sheet(isPresented: $showAddSheet) {
                AddEditAppointmentSheet(viewModel: appointmentsVM)
            }
            .sheet(item: $selectedAppointment) { (appointment: AppointmentEntry) in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Label(appointment.what, systemImage: "calendar.badge.clock")
                            .font(.title2.bold())

                        HStack {
                            Image(systemName: "calendar")
                            Text("Datum: \(formattedDate(appointment.date))")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)

                        if !appointment.address.isEmpty {
                            Divider()
                            Text("📍 Adresse")
                                .font(.headline)
                            Button {
                                let encoded = appointment.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(appointment.address)
                                        .underline()
                                }
                                .foregroundColor(.blue)
                                .font(.body)
                            }
                        }

                        if let notes = appointment.notes, !notes.isEmpty {
                            Divider()
                            Text("📝 Notizen")
                                .font(.headline)
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Keine weiteren Informationen.")
                                .foregroundColor(.secondary)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    PatientAppointmentsView()
}
