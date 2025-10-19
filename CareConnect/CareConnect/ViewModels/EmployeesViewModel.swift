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
    
    @Published var employees: [Employee] = []
    private let service: FirebaseServiceType

    init(service: FirebaseServiceType = FirebaseMockService()) {
        self.service = service
    }

    func load() async {
        do { employees = try await service.fetchEmployees() }
        catch { print("Fehler Mitarbeiter: \(error)") }
    }
}

