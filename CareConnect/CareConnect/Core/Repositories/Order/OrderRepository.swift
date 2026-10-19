//
//  OrderRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

protocol OrderRepository {
    /// Alle Aufträge live, neueste zuerst
    func listenAll(orgId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle
    func listen(orgId: String, id: String, onChange: @escaping (Order?) -> Void) -> ListenerHandle
    /// Aufträge eines Patienten live
    func listen(orgId: String, patientId: String, onChange: @escaping ([Order]) -> Void) -> ListenerHandle
    func create(_ order: Order, orgId: String) async throws
    /// Mehrere Aufträge auf einmal, z. B. aus einer wiederkehrenden Verordnung
    func createMany(_ orders: [Order], orgId: String) async throws
    func update(orgId: String, id: String, fields: [String: Any]) async throws
    /// Annehmen in einer Transaktion, damit nicht zwei denselben Auftrag bekommen
    func accept(orgId: String, id: String, employeeId: String) async throws
    func complete(orgId: String, id: String, report: CompletionReport) async throws
    func delete(orgId: String, id: String) async throws
}
