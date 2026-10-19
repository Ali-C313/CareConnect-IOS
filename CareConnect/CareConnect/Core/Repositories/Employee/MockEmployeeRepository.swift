//
//  MockEmployeeRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Mitarbeiter und Dokumente aus den Beispieldaten
final class MockEmployeeRepository: EmployeeRepository {
    private var employees = MockData.employees
    private var documents: [EmployeeDocument] = [EmployeeDocument(fileName: "Arbeitsvertrag.pdf")]

    func listenAll(orgId: String, onChange: @escaping ([Employee]) -> Void) -> ListenerHandle {
        onChange(employees)
        return MockListener()
    }

    func listen(orgId: String, id: String, onChange: @escaping (Employee?) -> Void) -> ListenerHandle {
        onChange(employees.first { $0.id == id })
        return MockListener()
    }

    func updateStatus(orgId: String, id: String, status: StaffStatus) async throws {
        guard let index = employees.firstIndex(where: { $0.id == id }) else { return }
        employees[index].status = status
    }

    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws {}

    // Dokumente
    func listenDocuments(orgId: String, employeeId: String, onChange: @escaping ([EmployeeDocument]) -> Void) -> ListenerHandle {
        onChange(documents)
        return MockListener()
    }

    func addDocument(orgId: String, employeeId: String, fileName: String, data: Data) async throws {
        documents.append(EmployeeDocument(fileName: fileName))
    }

    func deleteDocument(orgId: String, employeeId: String, document: EmployeeDocument) async throws {
        documents.removeAll { $0.fileName == document.fileName }
    }
}
