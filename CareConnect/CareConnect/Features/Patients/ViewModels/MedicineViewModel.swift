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
    @Published var medicines: [MedicineEntry] = []
    @Published var showAddSheet: Bool = false
    @Published var showEditSheet: Bool = false
    @Published var editingMedicine: MedicineEntry?

    private var db = Firestore.firestore()

    init() {
        fetchMedicines()
    }

    func fetchMedicines() {
        db.collection("medicines").addSnapshotListener { querySnapshot, error in
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
        do {
            _ = try db.collection("medicines").addDocument(from: medicine)
        } catch {
            print("Fehler beim Hinzufügen: \(error.localizedDescription)")
        }
    }

    func deleteMedicine(_ medicine: MedicineEntry) {
        guard let id = medicine.id else { return }
        db.collection("medicines").document(id).delete { error in
            if let error = error {
                print("Fehler beim Löschen: \(error.localizedDescription)")
            }
        }
    }
}
