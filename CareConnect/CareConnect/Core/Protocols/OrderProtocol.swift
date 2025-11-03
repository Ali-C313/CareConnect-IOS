//
//  OrderProtocol.swift
//  CareConnect
//
//  Created by Ali Chehab on 31.10.25.
//

import Foundation

protocol OrderProtocol {
    /// Auftrag erstellen
    func create(_ order: Order) async throws
    /// Auftrag aktualisieren
    func update(id: String, fields: [String: Any]) async throws
    /// Aufträge laden
    func fetchAll() async throws -> [Order]
}
