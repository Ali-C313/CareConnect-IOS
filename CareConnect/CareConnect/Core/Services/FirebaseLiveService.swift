//
//  FirebaseLiveService.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class FirebaseLiveService: FirebaseServiceType {
    
    private let db = Firestore.firestore()
    private var employeesRef: CollectionReference { db.collection("employees") }
    private var patientsRef:  CollectionReference { db.collection("patients") }
    private var ordersRef:    CollectionReference { db.collection("orders") }

    /// Mitarbeiter laden
    func fetchEmployees() async throws -> [Employee] {
        let snap = try await employeesRef.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Employee.self) }
    }
    /// Patienten laden
    func fetchPatients() async throws -> [Patient] {
        let snap = try await patientsRef.getDocuments()
        var results: [Patient] = []
        for doc in snap.documents {
            do {
                var patient = try doc.data(as: Patient.self)
                // UID fallback
                if patient.uid == nil {
                    patient.uid = doc.documentID
                }
                results.append(patient)
            } catch {
                print("❌ Patient-Decode:", doc.documentID, error)
            }
        }
        return results
    }
    /// Aufträge laden
    func fetchOrders() async throws -> [Order] {
        let snap = try await ordersRef.getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Order.self) }
    }
    /// Patient laden
    func fetchPatient(by id: String) async throws -> Patient? {
        let doc = try await patientsRef.document(id).getDocument()
        return try? doc.data(as: Patient.self)
    }

    /// Auftrag aktualisieren
    func updateOrder(id: String, fields: [String: Any]) async throws {
        guard !id.isEmpty else { throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Order-ID"]) }
        try await ordersRef.document(id).setData(fields, merge: true)
    }
    /// Mitarbeiter aktualisieren
    func updateEmployee(id: String, fields: [String: Any]) async throws {
        guard !id.isEmpty else { throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Mitarbeiter-ID"]) }
        try await employeesRef.document(id).setData(fields, merge: true)
    }
    /// Patient aktualisieren
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
        print("✅ Patient aktualisiert: \(documentID)")
    }

    /// Live-Listener
    func listen<T: Decodable>(to collection: String, as type: T.Type,
                              onChange: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration {
        return db.collection(collection).addSnapshotListener { snap, err in
            if let err = err { onChange(.failure(err)); return }
            guard let snap = snap else { onChange(.success([])); return }

            var results: [T] = []
            do {
                if T.self == Patient.self {
                    // Patient UID fallback
                    let patients: [Patient] = try snap.documents.map { doc in
                        var p = try doc.data(as: Patient.self)
                        if p.uid == nil { p.uid = doc.documentID }
                        return p
                    }
                    // forced cast is safe due to T.self check
                    results = patients as! [T]
                } else {
                    results = try snap.documents.map { doc in
                        try doc.data(as: T.self)
                    }
                }
                // Kompaktes Logging
                #if DEBUG
                print("📡 listen(\(collection)) → \(results.count) items")
                #endif
                onChange(.success(results))
            } catch {
                print("❌ Live-Decode:", collection, error)
                onChange(.failure(error))
            }
        }
    }
}