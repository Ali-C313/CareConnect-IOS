//
//  PDFStorageProtocol.swift
//  CareConnect
//
//  Created by Ali Chehab on 31.10.25.
//

import Foundation

protocol PDFStorageProtocol {
    /// PDF laden
    func downloadPDF(at path: String) async throws -> URL
}
