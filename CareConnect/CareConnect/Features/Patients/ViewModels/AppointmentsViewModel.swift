//
//  AppointmentsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 06.11.25.
//


import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class AppointmentsViewModel: ObservableObject {
    
    @Published var appointments: [AppointmentEntry] = []
    @Published var showAddEditSheet: Bool = false
    @Published var editingAppointment: AppointmentEntry? = nil

    private let db = Firestore.firestore()

    // MARK: - Funktionen
    func addAppointment(_ newAppointment: AppointmentEntry) {
        appointments.append(newAppointment)
        addAppointmentToFirestore(newAppointment)
    }

    func updateAppointment(_ updated: AppointmentEntry) {
        if let index = appointments.firstIndex(where: { $0.id == updated.id }) {
            appointments[index] = updated
            updateAppointmentInFirestore(updated)
        }
    }

    func deleteAppointment(at offsets: IndexSet) {
        let toDelete = offsets.map { appointments[$0] }
        appointments.remove(atOffsets: offsets)
        for appointment in toDelete {
            deleteAppointmentFromFirestore(appointment)
        }
    }

    func deleteAppointment(_ appointment: AppointmentEntry) {
        appointments.removeAll { $0.id == appointment.id }
        deleteAppointmentFromFirestore(appointment)
    }

    func prepareForEditing(_ appointment: AppointmentEntry) {
        editingAppointment = appointment
        showAddEditSheet = true
    }
    
    func saveAppointment(_ appointment: AppointmentEntry) {
        if let existing = editingAppointment {
            // Update existing appointment
            updateAppointment(appointment)
            editingAppointment = nil
        } else {
            // Add new appointment
            addAppointment(appointment)
        }
        showAddEditSheet = false
    }

    // MARK: - Firebase Firestore Integration
    func fetchAppointments() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ Kein eingeloggter Benutzer gefunden.")
            return
        }
        
        db.collection("patients").document(userId).collection("appointments")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Fehler beim Laden: \(error.localizedDescription)")
                    return
                }
                
                self.appointments = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: AppointmentEntry.self)
                } ?? []
            }
    }

    func addAppointmentToFirestore(_ appointment: AppointmentEntry) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            _ = try db.collection("patients").document(userId)
                .collection("appointments")
                .addDocument(from: appointment)
            print("✅ Termin erfolgreich gespeichert.")
        } catch {
            print("❌ Fehler beim Speichern: \(error.localizedDescription)")
        }
    }

    func updateAppointmentInFirestore(_ appointment: AppointmentEntry) {
        guard let userId = Auth.auth().currentUser?.uid,
              let id = appointment.id else { return }
        do {
            try db.collection("patients").document(userId)
                .collection("appointments")
                .document(id)
                .setData(from: appointment)
            print("✅ Termin aktualisiert.")
        } catch {
            print("❌ Fehler beim Aktualisieren: \(error.localizedDescription)")
        }
    }

    func deleteAppointmentFromFirestore(_ appointment: AppointmentEntry) {
        guard let userId = Auth.auth().currentUser?.uid,
              let id = appointment.id else { return }
        db.collection("patients").document(userId)
            .collection("appointments")
            .document(id)
            .delete { error in
                if let error = error {
                    print("❌ Fehler beim Löschen: \(error.localizedDescription)")
                } else {
                    print("🗑️ Termin gelöscht.")
                }
            }
    }
}
