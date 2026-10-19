//
//  FirestoreListener.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Verpackt ListenerRegistration, damit ViewModels kein Firestore kennen müssen
final class FirestoreListener: ListenerHandle {
    private var registration: ListenerRegistration?

    init(_ registration: ListenerRegistration) {
        self.registration = registration
    }

    func remove() {
        registration?.remove()
        registration = nil
    }
}

extension Query {
    /// Live-Liste, kaputte Dokumente werden übersprungen
    func listen<T: Decodable>(as type: T.Type, onChange: @escaping ([T]) -> Void) -> ListenerHandle {
        let registration = addSnapshotListener { snapshot, error in
            if let error {
                print("Listener-Fehler:", error.localizedDescription)
                onChange([])
                return
            }
            let items = snapshot?.documents.compactMap { document -> T? in
                do {
                    return try document.data(as: T.self)
                } catch {
                    print("Decode-Fehler \(T.self) \(document.documentID):", error.localizedDescription)
                    return nil
                }
            } ?? []
            onChange(items)
        }
        return FirestoreListener(registration)
    }
}

extension DocumentReference {
    /// Ein Dokument live, nil wenn es nicht existiert
    /// - Parameter ignoreErrors: true = bei Fehlern nichts melden (z. B. Mitgliedsrolle)
    func listen<T: Decodable>(
        as type: T.Type,
        ignoreErrors: Bool = false,
        onChange: @escaping (T?) -> Void
    ) -> ListenerHandle {
        let registration = addSnapshotListener { snapshot, error in
            if let error {
                print("Listener-Fehler:", error.localizedDescription)
                if !ignoreErrors { onChange(nil) }
                return
            }
            guard let snapshot, snapshot.exists else {
                onChange(nil)
                return
            }
            onChange(try? snapshot.data(as: T.self))
        }
        return FirestoreListener(registration)
    }

    /// Nur ob das Dokument existiert
    func listenExists(onChange: @escaping (Bool) -> Void) -> ListenerHandle {
        let registration = addSnapshotListener { snapshot, _ in
            onChange(snapshot?.exists ?? false)
        }
        return FirestoreListener(registration)
    }
}
