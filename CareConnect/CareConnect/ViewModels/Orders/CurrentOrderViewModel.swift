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
    @Published var patient: Patient?
    @Published var employee: Employee?
    @Published var isLoading = false
    @Published var error: String?

    private let service: FirebaseServiceType

    init(service: FirebaseServiceType = FirebaseLiveService()) { self.service = service }

    func loadDetails(for order: Order) async {
        isLoading = true; defer { isLoading = false }
        do {
            async let patients = service.fetchPatients()
            async let employees = service.fetchEmployees()
            let (p, e) = try await (patients, employees)
            self.patient  = p.first { $0.id == order.patientId }
            self.employee = e.first { $0.id == order.employeeId }
        } catch { self.error = "Daten konnten nicht geladen werden: \(error.localizedDescription)" }
    }
}
