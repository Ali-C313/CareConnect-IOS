//
//  PDFCardViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import Combine

@MainActor
final class PDFCardViewModel: ObservableObject {
    /// Lokale PDF-URL
    @Published var localURL: URL?
    /// Fehlertext
    @Published var error: String?

    private let repo: PDFStorageProtocol

    /// Initialisiert Repo
    init(repo: PDFStorageProtocol? = nil) {
        self.repo = repo ?? FirebasePDFStorageRepository()
    }

    /// PDF laden
    func loadPDF(storagePath: String) async {
        do { localURL = try await repo.downloadPDF(at: storagePath) }
        catch { self.error = "PDF konnte nicht geladen werden: \(error.localizedDescription)" }
    }
}
