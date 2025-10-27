//
//  FirebaseService.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol FirebaseServiceType {
    func fetchEmployees() async throws -> [Employee]
    func fetchPatients()  async throws -> [Patient]
    func fetchOrders()    async throws -> [Order]
    func fetchPatient(by id: String) async throws -> Patient?
    func updateOrder(id: String, fields: [String: Any]) async throws
    func updateEmployee(id: String, fields: [String: Any]) async throws
    func updatePatient(id: String, fields: [String: Any]) async throws
    func listen<T: Decodable>(to collection: String, as type: T.Type,
                              onChange: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration
}

final class FirebaseLiveService: FirebaseServiceType {
    private let db = Firestore.firestore()
    private var employeesRef: CollectionReference { db.collection("employees") }
    private var patientsRef:  CollectionReference { db.collection("patients") }
    private var ordersRef:    CollectionReference { db.collection("orders") }

    func fetchEmployees() async throws -> [Employee] {
        let snap = try await employeesRef.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Employee.self) }
    }
    func fetchPatients() async throws -> [Patient] {
        let snap = try await patientsRef.getDocuments()
        print("📥 Firebase fetchPatients: \(snap.documents.count) Dokumente gefunden")
        return snap.documents.compactMap { try? $0.data(as: Patient.self) }
    }
    func fetchOrders() async throws -> [Order] {
        let snap = try await ordersRef.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Order.self) }
    }
    func fetchPatient(by id: String) async throws -> Patient? {
        let doc = try await patientsRef.document(id).getDocument()
        return try? doc.data(as: Patient.self)
    }

    func updateOrder(id: String, fields: [String: Any]) async throws {
        guard !id.isEmpty else { throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Order-ID"]) }
        try await ordersRef.document(id).setData(fields, merge: true)
    }
    func updateEmployee(id: String, fields: [String: Any]) async throws {
        guard !id.isEmpty else { throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Mitarbeiter-ID"]) }
        try await employeesRef.document(id).setData(fields, merge: true)
    }
    func updatePatient(id: String, fields: [String: Any]) async throws {
        var documentID = id
        if documentID.isEmpty, let uid = Auth.auth().currentUser?.uid {
            documentID = uid
        }
        guard !documentID.isEmpty else {
            throw NSError(domain: "FirebaseService", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Fehlende Patienten-ID"])
        }
        try await patientsRef.document(documentID).setData(fields, merge: true)
        print("✅ Patient-Daten aktualisiert für ID: \(documentID)")
    }

    func listen<T: Decodable>(to collection: String, as type: T.Type,
                              onChange: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration {
        return db.collection(collection).addSnapshotListener { snap, err in
            if let err = err { onChange(.failure(err)); return }
            let list = snap?.documents.compactMap { try? $0.data(as: T.self) } ?? []
            onChange(.success(list))
        }
    }
}
