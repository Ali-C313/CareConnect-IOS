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
    /// Aktueller Status
    @Published var current: StaffStatus
    /// Fehlermeldung
    @Published var error: String?

    private let employeeRepo: EmployeeProtocol
    private let currentEmployeeIdProvider: () -> String?

    /// Initialisiert Repo
    init(current: StaffStatus,
         employeeRepo: EmployeeProtocol? = nil,
         currentEmployeeIdProvider: @escaping () -> String?) {
        self.current = current
        self.employeeRepo = employeeRepo ?? FirebaseEmployeeRepository()
        self.currentEmployeeIdProvider = currentEmployeeIdProvider
    }

    /// Status setzen
    func set(_ status: StaffStatus) async {
        guard let id = currentEmployeeIdProvider() else { return }
        do { try await employeeRepo.update(id: id, fields: ["status": status.rawValue]); current = status }
        catch { self.error = "Status konnte nicht aktualisiert werden: \(error.localizedDescription)" }
    }
}
