//
//  StorageRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Dateien hochladen und löschen
protocol StorageRepository {
    /// Lädt die Datei hoch und gibt die Download-URL zurück
    func upload(data: Data, path: String, contentType: String) async throws -> String
    func delete(path: String) async throws
}
