//
//  MedicineViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class MedicineViewModel: ObservableObject {
    private let patientId: String

    @Published var medicines: [MedicineEntry] = []
    @Published var showAddSheet: Bool = false
    @Published var showEditSheet: Bool = false
    @Published var editingMedicine: MedicineEntry?

    private var db = Firestore.firestore()

    init(patientId: String) {
        self.patientId = patientId
        if patientId.trimmingCharacters(in: .whitespaces).isEmpty {
            print("❌ FEHLER: MedicineViewModel wurde mit leerer patientId initialisiert! Medikamente können NICHT gespeichert werden.")
        } else {
            print("✅ MedicineViewModel initialisiert mit patientId: \(patientId)")
        }
        fetchMedicines()
    }

    func fetchMedicines() {
        if patientId.trimmingCharacters(in: .whitespaces).isEmpty {
            print("❌ FEHLER: patientId ist leer – kann Medikamente NICHT laden!")
            return
        }
        db.collection("patients")
            .document(patientId)
            .collection("medicines")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Keine Medikamente gefunden.")
                    return
                }
                self.medicines = documents.compactMap { document in
                    try? document.data(as: MedicineEntry.self)
                }
            }
    }

    func addMedicine(_ medicine: MedicineEntry) {
        if patientId.trimmingCharacters(in: .whitespaces).isEmpty {
            print("❌ FEHLER: patientId ist leer – Medikament wird NICHT gespeichert!")
            return
        }
        do {
            _ = try db.collection("patients")
                .document(patientId)
                .collection("medicines")
                .addDocument(from: medicine)
        } catch {
            print("Fehler beim Hinzufügen: \(error.localizedDescription)")
        }
    }

    func deleteMedicine(_ medicine: MedicineEntry) {
        guard let id = medicine.id else { return }
        db.collection("patients")
            .document(patientId)
            .collection("medicines")
            .document(id)
            .delete { error in
                if let error = error {
                    print("Fehler beim Löschen: \(error.localizedDescription)")
                }
            }
    }
}
