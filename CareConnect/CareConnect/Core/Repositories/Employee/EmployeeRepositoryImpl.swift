//
//  EmployeeRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Mitarbeiter und Dokumente in Firestore und Storage
final class EmployeeRepositoryImpl: EmployeeRepository {
    private let storage: StorageRepository

    init(storage: StorageRepository) {
        self.storage = storage
    }

    private func ref(_ orgId: String) -> CollectionReference {
        FirebaseManager.shared.database.org(orgId).collection(CollectionNames.employees)
    }

    private func documentsRef(_ orgId: String, _ employeeId: String) -> CollectionReference {
        ref(orgId).document(employeeId).collection(CollectionNames.documents)
    }

    func listenAll(orgId: String, onChange: @escaping ([Employee]) -> Void) -> ListenerHandle {
        ref(orgId).listen(as: Employee.self) { employees in
            onChange(employees.sorted { $0.name < $1.name })
        }
    }

    func updateStatus(orgId: String, id: String, status: StaffStatus) async throws {
        try await ref(orgId).document(id).updateData(["status": status.rawValue])
    }

    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws {
        guard !id.isBlank else { throw AppError.missingId }
        try await ref(orgId).document(id).setData(fields, merge: true)
    }

    func listenDocuments(orgId: String, employeeId: String, onChange: @escaping ([EmployeeDocument]) -> Void) -> ListenerHandle {
        documentsRef(orgId, employeeId).listen(as: EmployeeDocument.self) { documents in
            onChange(documents.sorted { ($0.uploadedAt?.date ?? .distantPast) > ($1.uploadedAt?.date ?? .distantPast) })
        }
    }

    func addDocument(orgId: String, employeeId: String, fileName: String, data: Data) async throws {
        let path = "employeeDocuments/\(employeeId)/\(newId())-\(fileName)"
        let url = try await storage.upload(data: data, path: path, contentType: "application/pdf")
        let document = EmployeeDocument(fileName: fileName, downloadURL: url, uploadedAt: Timestamp(), storagePath: path)
        try documentsRef(orgId, employeeId).addDocument(from: document)
    }

    func deleteDocument(orgId: String, employeeId: String, document: EmployeeDocument) async throws {
        // Erst die Datei im Storage löschen, dann den Eintrag
        if let path = document.storagePath, !path.isEmpty {
            try? await storage.delete(path: path)
        }
        guard let id = document.documentId else { throw AppError.missingId }
        try await documentsRef(orgId, employeeId).document(id).delete()
    }
}
