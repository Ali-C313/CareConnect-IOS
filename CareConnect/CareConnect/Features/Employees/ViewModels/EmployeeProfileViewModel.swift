//
//  EmployeeProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Dokumente eines Mitarbeiters (Mitarbeiter selbst kommt aus dem AppStateViewModel)
@MainActor
@Observable
final class EmployeeProfileViewModel {
    private(set) var documents: [EmployeeDocument] = []
    private(set) var isUploading = false
    var errorMessage: String?

    private let container: AppContainer
    private var documentsListener: ListenerHandle?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    func startListening(employeeId: String) {
        guard documentsListener == nil, let orgId = container.currentOrgId, !employeeId.isEmpty else { return }
        documentsListener = container.employees.listenDocuments(orgId: orgId, employeeId: employeeId) { [weak self] list in
            self?.documents = list
        }
    }

    func stopListening() {
        documentsListener?.remove()
        documentsListener = nil
    }

    /// PDF aus dem fileImporter hochladen
    func uploadPDF(from url: URL, employeeId: String) {
        // Zugriff auf Dateien außerhalb der App freigeben
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else {
            errorMessage = tr("Upload fehlgeschlagen: {0}", url.lastPathComponent)
            return
        }
        let fileName = url.lastPathComponent
        let name = fileName.lowercased().hasSuffix(".pdf") ? fileName : "\(fileName).pdf"
        if documents.contains(where: { $0.fileName == name }) {
            errorMessage = tr("Diese Datei wurde bereits hochgeladen.")
            return
        }

        Task {
            isUploading = true
            defer { isUploading = false }
            do {
                let orgId = try container.requireOrgId()
                try await container.employees.addDocument(orgId: orgId, employeeId: employeeId, fileName: name, data: data)
            } catch {
                errorMessage = tr("Upload fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }

    func deleteDocument(_ document: EmployeeDocument, employeeId: String) {
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.employees.deleteDocument(orgId: orgId, employeeId: employeeId, document: document)
            } catch {
                errorMessage = tr("Löschen fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }
}
