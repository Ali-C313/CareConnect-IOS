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

    var body: some View {
        NavigationStack {
            List {
                ForEach(appointmentsVM.appointments) { appointment in
                    HStack {
                        Label("\(appointment.what) – \(formattedDate(appointment.date))", systemImage: "calendar")
                    }
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
