//
//  EmployeeRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Mitarbeiter einer Organisation
protocol EmployeeRepository {
    func listenAll(orgId: String, onChange: @escaping ([Employee]) -> Void) -> ListenerHandle
    func listen(orgId: String, id: String, onChange: @escaping (Employee?) -> Void) -> ListenerHandle
    func updateStatus(orgId: String, id: String, status: StaffStatus) async throws
    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws

    // Dokumente
    func listenDocuments(orgId: String, employeeId: String, onChange: @escaping ([EmployeeDocument]) -> Void) -> ListenerHandle
    func addDocument(orgId: String, employeeId: String, fileName: String, data: Data) async throws
    func deleteDocument(orgId: String, employeeId: String, document: EmployeeDocument) async throws
}
