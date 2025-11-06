//
//  AppointmentsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class AppointmentsViewModel: ObservableObject {
    
    @Published var appointments: [AppointmentEntry] = []
    @Published var showAddEditSheet: Bool = false
    @Published var editingAppointment: AppointmentEntry? = nil

    // MARK: - Funktionen
    func addAppointment(_ newAppointment: AppointmentEntry) {
        appointments.append(newAppointment)
    }

    func updateAppointment(_ updated: AppointmentEntry) {
        if let index = appointments.firstIndex(where: { $0.id == updated.id }) {
            appointments[index] = updated
        }
    }

    func deleteAppointment(at offsets: IndexSet) {
        appointments.remove(atOffsets: offsets)
    }

    func deleteAppointment(_ appointment: AppointmentEntry) {
        appointments.removeAll { $0.id == appointment.id }
    }

    func prepareForEditing(_ appointment: AppointmentEntry) {
        editingAppointment = appointment
        showAddEditSheet = true
    }
}
