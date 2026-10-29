//
//  StorageRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseStorage

/// Dateien in Firebase Storage
final class StorageRepositoryImpl: StorageRepository {
    private var storage: Storage { FirebaseManager.shared.storage }

    func upload(data: Data, path: String, contentType: String) async throws -> String {
        let ref = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        _ = try await ref.putDataAsync(data, metadata: metadata)
        return try await ref.downloadURL().absoluteString
    }

    func delete(path: String) async throws {
        try await storage.reference(withPath: path).delete()
    }
}
