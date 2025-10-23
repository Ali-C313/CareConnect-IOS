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
    @Published var employee: Employee
    @Published var isSaving = false
    @Published var error: String?

    private let employeeRepo: EmployeeRepository

    init(employee: Employee, employeeRepo: EmployeeRepository = FirebaseEmployeeRepository()) {
        self.employee = employee; self.employeeRepo = employeeRepo
    }

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
