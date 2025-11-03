//
//  EditProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    /// Mitarbeiterdaten
    @Published var employee: Employee
    /// Speicherstatus
    @Published var isSaving = false
    /// Fehlermeldung
    @Published var error: String?

    nonisolated private let employeeRepo: EmployeeProtocol

    /// Initialisiert Repo
    init(employee: Employee, employeeRepo: EmployeeProtocol? = nil) {
        self.employee = employee
        self.employeeRepo = employeeRepo ?? FirebaseEmployeeRepository()
    }

    /// Änderungen speichern
    func save() async -> Bool {
        guard let id = employee.id else { return false }
        isSaving = true; defer { isSaving = false }
        do {
            try await employeeRepo.update(id: id, fields: [
                "firstName": employee.firstName,
                "lastName": employee.lastName,
                "role": employee.role,
                "email": employee.email
            ]); return true
        } catch { self.error = "Fehler beim Speichern: \(error.localizedDescription)"; return false }
    }
}
