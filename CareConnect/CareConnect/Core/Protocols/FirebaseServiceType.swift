//
//  FirebaseServiceType.swift
//  CareConnect
//
//  Created by Ali Chehab on 31.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

protocol FirebaseServiceType {
    /// Mitarbeiter laden
    func fetchEmployees() async throws -> [Employee]
    /// Patienten laden
    func fetchPatients()  async throws -> [Patient]
    /// Aufträge laden
    func fetchOrders()    async throws -> [Order]
    /// Patient laden
    func fetchPatient(by id: String) async throws -> Patient?
    /// Auftrag aktualisieren
    func updateOrder(id: String, fields: [String: Any]) async throws
    /// Mitarbeiter aktualisieren
    func updateEmployee(id: String, fields: [String: Any]) async throws
    /// Patient aktualisieren
    func updatePatient(id: String, fields: [String: Any]) async throws
    /// Live-Listener starten
    func listen<T: Decodable>(to collection: String, as type: T.Type,
                              onChange: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration
    /// Auftrag löschen
    func deleteOrder(id: String) async throws
}

