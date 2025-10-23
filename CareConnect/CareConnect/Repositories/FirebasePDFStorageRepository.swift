//
//  FirebasePDFStorageRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

protocol PDFStorageRepository {
    func downloadPDF(at path: String) async throws -> URL
}

final class FirebasePDFStorageRepository: PDFStorageRepository {
    private let storage = Storage.storage()

    /// Lädt eine PDF-Datei in den richtigen Bereich hoch (user-basiert)
    func uploadPDF(
        data: Data,
        fileName: String,
        forPatientId patientId: String? = nil
    ) async throws -> URL {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht angemeldet"])
        }

        // 1️⃣ Pfad basierend auf Benutzerrolle definieren
        var path: String

        if let patientId = patientId {
            // Mitarbeiter lädt PDF für einen Patienten hoch
            path = "patientDocuments/\(patientId)/\(fileName)"
        } else {
            // Mitarbeiter lädt PDF für sich selbst hoch
            path = "employeeDocuments/\(currentUser.uid)/\(fileName)"
        }

        // 2️⃣ Upload in Firebase Storage
        let ref = storage.reference(withPath: path)
        _ = try await ref.putDataAsync(data, metadata: nil)

        // 3️⃣ Download-URL zurückgeben
        return try await ref.downloadURL()
    }

    /// Lädt eine PDF-Datei herunter (wie gehabt)
    func downloadPDF(at path: String) async throws -> URL {
        let ref = storage.reference(withPath: path)
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
        _ = try await ref.writeAsync(toFile: tmp)
        return tmp
    }
}
