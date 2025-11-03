//
//  EmployeesViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation
import Combine

@MainActor
final class EmployeesViewModel: ObservableObject {
    /// Mitarbeiterliste
    @Published var employees: [Employee] = []
    private let service: FirebaseServiceType = FirebaseLiveService()
    
    /// Mitarbeiter laden
    func loadEmployees() async {
        do {
            employees = try await service.fetchEmployees()
        } catch {
            print("❌ Fehler beim Laden der Mitarbeiter:", error)
        }
    }
}
