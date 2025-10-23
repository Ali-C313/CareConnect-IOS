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
    @Published var localURL: URL?
    @Published var error: String?

    private let repo: PDFStorageRepository

    init(repo: PDFStorageRepository = FirebasePDFStorageRepository()) { self.repo = repo }

    func loadPDF(storagePath: String) async {
        do { localURL = try await repo.downloadPDF(at: storagePath) }
        catch { self.error = "PDF konnte nicht geladen werden: \(error.localizedDescription)" }
    }
}
