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
    
    private func safeDecode<T: Decodable>(_ document: QueryDocumentSnapshot, as type: T.Type) -> T? {
        do {
            return try document.data(as: T.self)
        } catch {
            print("⚠️ Decode error for \(T.self): \(document.documentID) → \(error.localizedDescription)")
            return nil
        }
    }

    /// Mitarbeiter laden
    func fetchEmployees() async throws -> [Employee] {
        do {
            let snap = try await employeesRef.getDocuments()
            return snap.documents.compactMap { safeDecode($0, as: Employee.self) }
        } catch {
            print("❌ Firestore fetchEmployees failed:", error.localizedDescription)
            return []
        }
    }
    /// Patienten laden
    func fetchPatients() async throws -> [Patient] {
        do {
            let snap = try await patientsRef.getDocuments()
            var results: [Patient] = []
            for doc in snap.documents {
                if var patient = safeDecode(doc, as: Patient.self) {
                    if patient.uid == nil {
                        patient.uid = doc.documentID
                    }
                    results.append(patient)
                }
            }
            return results
        } catch {
            print("❌ Firestore fetchPatients failed:", error.localizedDescription)
            return []
        }
    }
    /// Aufträge laden
    func fetchOrders() async throws -> [Order] {
        do {
            let snap = try await ordersRef.getDocuments()
            return snap.documents.compactMap { safeDecode($0, as: Order.self) }
        } catch {
            print("❌ Firestore fetchOrders failed:", error.localizedDescription)
            return []
        }
    }
    /// Patient laden
    func fetchPatient(by id: String) async throws -> Patient? {
        guard !id.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("⚠️ fetchPatient: leere ID übergeben")
            return nil
        }
        do {
            let doc = try await patientsRef.document(id).getDocument()
            return try? doc.data(as: Patient.self)
        } catch {
            print("❌ Firestore fetchPatient(\(id)) failed:", error.localizedDescription)
            return nil
        }
    }

    /// Auftrag aktualisieren
    func updateOrder(id: String, fields: [String: Any]) async throws {
        guard !id.isEmpty else { throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Order-ID"]) }
        try await ordersRef.document(id).setData(fields, merge: true)
    }
    /// Auftrag löschen
    func deleteOrder(id: String) async throws {
        guard !id.isEmpty else {
            throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fehlende Order-ID"])
        }
        try await ordersRef.document(id).delete()
        print("🗑️ Auftrag gelöscht: \(id)")
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
            if let err = err {
                print("⚠️ Live listener error on \(collection):", err.localizedDescription)
                onChange(.success([]))
                return
            }
            guard let snap = snap else {
                print("⚠️ Empty snapshot for \(collection)")
                onChange(.success([]))
                return
            }

            var results: [T] = []
            do {
                if T.self == Patient.self {
                    let patients: [Patient] = try snap.documents.compactMap { doc in
                        var p = try doc.data(as: Patient.self)
                        if p.uid == nil { p.uid = doc.documentID }
                        return p
                    }
                    results = patients as! [T]
                } else {
                    results = try snap.documents.compactMap { doc in
                        try doc.data(as: T.self)
                    }
                }

                #if DEBUG
                print("📡 listen(\(collection)) → \(results.count) items")
                #endif
                onChange(.success(results))
            } catch {
                print("❌ Live-Decode (\(collection)):", error.localizedDescription)
                onChange(.failure(error))
            }
        }
    }
}
