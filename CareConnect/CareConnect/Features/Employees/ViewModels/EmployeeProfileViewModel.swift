//
//  EmployeeProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Combine
import UniformTypeIdentifiers

struct EmployeeDocument: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var fileName: String
    var downloadURL: String
    var uploadedAt: Date = Date()
}

/// Arbeitszeitmodell
struct WorkSchedule: Codable, Hashable {
    var weeklyHours: Int
    var shiftStart: String
    var shiftEnd: String
    var workDays: [String]
}

/// Mitarbeiterprofil-VM
@MainActor
final class EmployeeProfileViewModel: ObservableObject {
    /// Mitarbeiterdaten
    @Published var employee: Employee?
    /// Dokumente
    @Published var documents: [EmployeeDocument] = []
    /// Arbeitszeiten
    @Published var workSchedule: WorkSchedule = .init(weeklyHours: 40, shiftStart: "08:00", shiftEnd: "16:30", workDays: ["Mo","Di","Mi","Do","Fr"])
    /// Ladezustand
    @Published var isLoading = false
    /// Fehlertext
    @Published var errorMessage: String?
    /// Angezeigtes PDF
    @Published var showingPDF: EmployeeDocument?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Laden
    /// Daten laden
    func load(employeeId: String) async {
        isLoading = true
        defer { isLoading = false }
        await loadEmployee(employeeId: employeeId)
        await loadDocuments(employeeId: employeeId)
        await loadWorkSchedule(employeeId: employeeId)
    }

    /// Mitarbeiter laden
    private func loadEmployee(employeeId: String) async {
        do {
            let cachedSnap = try? await db.collection("employees").document(employeeId).getDocument(source: .cache)
            if let cachedData = cachedSnap, let emp = try? cachedData.data(as: Employee.self) {
                self.employee = emp
            }
        }
        do {
            let snap = try await db.collection("employees").document(employeeId).getDocument()
            if let emp = try? snap.data(as: Employee.self) {
                self.employee = emp
            } else {
                self.errorMessage = "Fehler beim Laden des Mitarbeiterprofils."
            }
        } catch {
            self.errorMessage = "Mitarbeiter konnte nicht geladen werden: \(error.localizedDescription)"
        }
    }

    /// Dokumente laden
    private func loadDocuments(employeeId: String) async {
        do {
            let snap = try await db.collection("employees").document(employeeId)
                .collection("documents")
                .order(by: "uploadedAt", descending: true)
                .getDocuments()
            self.documents = try snap.documents.map { try $0.data(as: EmployeeDocument.self) }
        } catch {
            print("⚠️ Dokumente laden fehlgeschlagen:", error.localizedDescription)
        }
    }

    /// Arbeitszeiten laden
    private func loadWorkSchedule(employeeId: String) async {
        do {
            let doc = try await db.collection("employees").document(employeeId).getDocument()
            if let data = doc.data(),
               let ws = data["workSchedule"] as? [String: Any],
               let weeklyHours = ws["weeklyHours"] as? Int,
               let shiftStart = ws["shiftStart"] as? String,
               let shiftEnd = ws["shiftEnd"] as? String,
               let workDays = ws["workDays"] as? [String] {
                self.workSchedule = .init(weeklyHours: weeklyHours, shiftStart: shiftStart, shiftEnd: shiftEnd, workDays: workDays)
            }
        } catch {
            print("⚠️ Arbeitszeiten laden fehlgeschlagen:", error.localizedDescription)
        }
    }

    // MARK: - Dokument hochladen (PDF)
    /// PDF importieren
    func importPDF(from pickedURL: URL, employeeId: String) async {
        do {
            guard !documents.contains(where: { $0.fileName == pickedURL.lastPathComponent }) else {
                self.errorMessage = "Diese Datei wurde bereits hochgeladen."
                return
            }
            // Security scoped (für iCloud/Dateien)
            let needsAccess = pickedURL.startAccessingSecurityScopedResource()
            defer { if needsAccess { pickedURL.stopAccessingSecurityScopedResource() } }

            let data = try Data(contentsOf: pickedURL)
            let filename = suggestedFileName(from: pickedURL) ?? "Dokument-\(UUID().uuidString).pdf"
            let storageRef = storage.reference(withPath: "employeeDocuments/\(employeeId)/\(UUID().uuidString)-\(filename)")

            // ✅ Neues Metadata-Objekt manuell anlegen
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"

            // ✅ Upload-Aufruf (neue Signatur)
            _ = try await storageRef.putDataAsync(data, metadata: metadata)

            let url = try await storageRef.downloadURL()

            // In Firestore persistieren (Subcollection)
            let doc = EmployeeDocument(fileName: filename, downloadURL: url.absoluteString, uploadedAt: Date())
            try db.collection("employees").document(employeeId)
                .collection("documents")
                .document(doc.id)
                .setData(from: doc)

            // UI aktualisieren
            documents.insert(doc, at: 0)
        } catch {
            self.errorMessage = "Upload fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    // MARK: - Dokument löschen (Firestore + Storage)
    /// Dokument löschen
    func deleteDocument(_ document: EmployeeDocument, employeeId: String) async {
        do {
            // Zuerst Firestore-Dokument löschen
            try await db.collection("employees")
                .document(employeeId)
                .collection("documents")
                .document(document.id)
                .delete()

            // Dann Datei aus Firebase Storage löschen
            let path = "employeeDocuments/\(employeeId)/"
            let storageRef = storage.reference(withPath: path)
            let allFiles = try await storageRef.listAll()
            if let item = allFiles.items.first(where: { $0.fullPath.contains(document.fileName) }) {
                try await item.delete()
            }

            // UI aktualisieren
            await MainActor.run {
                withAnimation {
                    self.documents.removeAll { $0.id == document.id }
                }
            }
        } catch {
            print("⚠️ Dokument löschen fehlgeschlagen:", error.localizedDescription)
            await MainActor.run {
                self.errorMessage = "Löschen fehlgeschlagen: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Hilfen
    /// Dateiname vorschlagen
    private func suggestedFileName(from url: URL) -> String? {
        if url.pathExtension.lowercased() == "pdf" { return url.lastPathComponent }
        return url.deletingPathExtension().lastPathComponent + ".pdf"
    }
}
