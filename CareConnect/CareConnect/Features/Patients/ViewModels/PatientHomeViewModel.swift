//
//  PatientHomeViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class PatientHomeViewModel: ObservableObject {
    // Öffentliche UI-Daten
    @Published var recentOrders: [DisplayOrder] = []
    @Published var activeOrder: DisplayOrder?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Leichtgewichtiges Modell nur für die Karten/Liste
    struct DisplayOrder: Identifiable {
        let id: String
        let title: String
        let state: String
        let dueDate: Date?
        let createdAt: Date?
    }

    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    // Lädt Historie + aktiven Auftrag für eine User-ID
    @MainActor
    func load(for userId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Historie: letzte 10 Aufträge des Patienten
            let historySnap = try await db.collection("orders")
                .whereField("createdBy", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .getDocuments()

            let history: [DisplayOrder] = historySnap.documents.map { doc in
                let data = doc.data()
                let title = (data["description"] as? String) ?? (data["patientName"] as? String) ?? "Auftrag"
                let state = (data["state"] as? String) ?? "unbekannt"
                let dueDate = (data["dueDate"] as? Timestamp)?.dateValue()
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                return DisplayOrder(id: doc.documentID, title: title, state: state, dueDate: dueDate, createdAt: createdAt)
            }
            self.recentOrders = history

            // Aktiver Auftrag (state == aktuell) – falls vorhanden
            let activeSnap = try await db.collection("orders")
                .whereField("createdBy", isEqualTo: userId)
                .whereField("state", isEqualTo: "aktuell")
                .limit(to: 1)
                .getDocuments()

            if let doc = activeSnap.documents.first {
                let data = doc.data()
                let title = (data["description"] as? String) ?? (data["patientName"] as? String) ?? "Aktiver Auftrag"
                let dueDate = (data["dueDate"] as? Timestamp)?.dateValue()
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                self.activeOrder = DisplayOrder(id: doc.documentID, title: title, state: "aktuell", dueDate: dueDate, createdAt: createdAt)
            } else {
                self.activeOrder = nil
            }
        } catch {
            self.errorMessage = "Konnte Aufträge nicht laden: \(error.localizedDescription)"
        }
    }
}
