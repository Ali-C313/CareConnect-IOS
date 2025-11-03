//
//  EmployeeProtocol.swift
//  CareConnect
//
//  Created by Ali Chehab on 31.10.25.
//

import Foundation

protocol EmployeeProtocol {
    /// Mitarbeiter laden
    func fetch(by id: String) async throws -> Employee
    /// Mitarbeiter aktualisieren
    func update(id: String, fields: [String: Any]) async throws
}
