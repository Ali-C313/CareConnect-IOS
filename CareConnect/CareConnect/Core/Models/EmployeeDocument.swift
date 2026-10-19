//
//  EmployeeDocument.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// PDF-Dokument eines Mitarbeiters (employees/{id}/documents)
struct EmployeeDocument: Identifiable, Codable, Hashable {
    // Android speichert ein leeres Feld "id", deshalb heißt die Dokument-ID hier anders
    @DocumentID var documentId: String?
    var fileName: String = "Dokument.pdf"
    var downloadURL: String = ""
    var uploadedAt: Timestamp?
    var storagePath: String?

    var id: String { documentId ?? fileName }
}
