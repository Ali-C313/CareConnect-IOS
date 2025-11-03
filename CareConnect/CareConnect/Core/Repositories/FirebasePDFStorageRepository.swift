//
//  FirebasePDFStorageRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

final class FirebasePDFStorageRepository: PDFStorageProtocol {
    private let storage = Storage.storage()

    /// PDF hochladen
    func uploadPDF(
        data: Data,
        fileName: String,
        forPatientId patientId: String? = nil
    ) async throws -> URL {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nicht angemeldet"])
        }

        var path: String
        if let patientId = patientId {
            path = "patientDocuments/\(patientId)/\(fileName)"
        } else {
            path = "employeeDocuments/\(currentUser.uid)/\(fileName)"
        }
        let ref = storage.reference(withPath: path)
        _ = try await ref.putDataAsync(data, metadata: nil)
        return try await ref.downloadURL()
    }

    /// PDF laden
    func downloadPDF(at path: String) async throws -> URL {
        let ref = storage.reference(withPath: path)
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
        _ = try await ref.writeAsync(toFile: tmp)
        return tmp
    }
}
