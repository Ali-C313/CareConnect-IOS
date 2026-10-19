//
//  MockStorageRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Tut so, als wäre die Datei hochgeladen
final class MockStorageRepository: StorageRepository {
    func upload(data: Data, path: String, contentType: String) async throws -> String {
        "https://example.com/\(path)"
    }

    func delete(path: String) async throws {}
}
