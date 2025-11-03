//
//  CurrentOrderViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class CurrentOrderViewModel: ObservableObject {
    /// Patientendaten
    @Published var patient: Patient?
    /// Mitarbeiterdaten
    @Published var employee: Employee?
    /// Ladezustand
    @Published var isLoading = false
    /// Fehlermeldung
    @Published var error: String?

    private let service: FirebaseServiceType

    /// Initialisiert Service
    init(service: FirebaseServiceType? = nil) {
        self.service = service ?? FirebaseLiveService()
    }

    /// Auftragsdetails laden
    func loadDetails(for order: Order) async {
        isLoading = true; defer { isLoading = false }
        do {
            let patients = try await service.fetchPatients()
            let employees = try await service.fetchEmployees()

            self.patient = patients.first(where: { patient in
                let uidMatch = (patient.uid ?? "") == (order.assignedTo ?? "")
                let fullName = ((patient.firstName ?? "") + " " + (patient.lastName ?? "")).trimmingCharacters(in: .whitespaces).lowercased()
                let email = (patient.email ?? "").lowercased()
                let nameMatch = fullName == order.patientName.lowercased()
                let emailMatch = email == order.patientName.lowercased()
                return uidMatch || nameMatch || emailMatch
            })

            self.employee = employees.first(where: { $0.id == order.assignedTo })
        } catch { self.error = "Daten konnten nicht geladen werden: \(error.localizedDescription)" }
    }
}
