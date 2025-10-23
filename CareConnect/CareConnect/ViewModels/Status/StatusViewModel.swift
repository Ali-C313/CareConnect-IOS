//
//  StatusViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class StatusViewModel: ObservableObject {
    @Published var current: StaffStatus
    @Published var error: String?

    private let employeeRepo: EmployeeRepository
    private let currentEmployeeIdProvider: () -> String?

    init(current: StaffStatus,
         employeeRepo: EmployeeRepository = FirebaseEmployeeRepository(),
         currentEmployeeIdProvider: @escaping () -> String?) {
        self.current = current
        self.employeeRepo = employeeRepo
        self.currentEmployeeIdProvider = currentEmployeeIdProvider
    }

    func set(_ status: StaffStatus) async {
        guard let id = currentEmployeeIdProvider() else { return }
        do { try await employeeRepo.update(id: id, fields: ["status": status.rawValue]); current = status }
        catch { self.error = "Status konnte nicht aktualisiert werden: \(error.localizedDescription)" }
    }
}
