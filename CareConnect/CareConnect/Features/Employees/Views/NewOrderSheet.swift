//
//  NewOrderSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
struct NewOrderSheet: View {
    /// Sheet sichtbar
    @Binding var isPresented: Bool
    var existingOrder: Order? = nil
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel

    /// Patient Id
    @State private var selectedPatientId = ""
    /// Beschreibung
    @State private var descriptionText = ""
    /// Fälligkeitsdatum
    @State private var dueDate = Date()
    /// Speicherstatus
    @State private var isSaving = false
    /// Alert anzeigen
    @State private var showAlert = false
    /// Alerttext
    @State private var alertMessage = ""

    private let db = Firestore.firestore()

    private var patientSection: some View {
        Section("Patient auswählen") {
            Picker("Patient", selection: $selectedPatientId) {
                ForEach(appState.patients, id: \.uid) { patient in
                    let displayName = ((patient.firstName ?? "") + " " + (patient.lastName ?? ""))
                        .trimmingCharacters(in: .whitespaces)
                    Text(displayName.isEmpty ? (patient.email ?? "Unbekannt") : displayName)
                        .tag(patient.uid ?? "")
                }
            }
        }
    }

    private var descriptionSection: some View {
        Section("Beschreibung") {
            TextField("Beschreibung des Auftrags", text: $descriptionText, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var dateSection: some View {
        Section("Zeitpunkt") {
            DatePicker(
                "Ausführungszeit",
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                patientSection
                descriptionSection
                dateSection
            }
            .navigationTitle(existingOrder != nil ? "Auftrag bearbeiten" : "Neuer Auftrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { Task { await saveOrder() } }
                        .disabled(selectedPatientId.isEmpty || descriptionText.isEmpty)
                }
            }
            .overlay(
                Group {
                    if isSaving {
                        ProgressView("Speichere Auftrag…")
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            )
            .alert("Hinweis", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if let order = existingOrder {
                    selectedPatientId = order.patientId ?? ""
                    descriptionText = order.description
                    if let due = order.dueDate {
                        dueDate = due.dateValue()
                    }
                }
            }
        }
    }

    /// Auftrag speichern
    private func saveOrder() async {
        guard !selectedPatientId.isEmpty, !descriptionText.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        let creatorUID = appState.currentUser?.uid ?? "unbekannt"

        guard let selectedPatient = appState.patients.first(where: { $0.uid == selectedPatientId }) else {
            alertMessage = "Fehler: Patient nicht gefunden."
            showAlert = true
            return
        }

        let displayName = ((selectedPatient.firstName ?? "") + " " + (selectedPatient.lastName ?? "")).trimmingCharacters(in: .whitespaces)

        // Wenn bestehender Auftrag bearbeitet wird
        if let existingOrder = existingOrder, let orderId = existingOrder.id {
            do {
                try await db.collection("orders").document(orderId).updateData([
                    "patientId": selectedPatient.uid ?? "",
                    "patientName": displayName.isEmpty ? (selectedPatient.email ?? "Unbekannter Patient") : displayName,
                    "description": descriptionText,
                    "dueDate": Timestamp(date: dueDate)
                ])
                if let index = appState.orders.firstIndex(where: { $0.id == orderId }) {
                    appState.orders[index].patientId = selectedPatient.uid
                    appState.orders[index].patientName = displayName
                    appState.orders[index].description = descriptionText
                    appState.orders[index].dueDate = Timestamp(date: dueDate)
                }
                alertMessage = "Auftrag erfolgreich aktualisiert."
                showAlert = true
                isPresented = false
                return
            } catch {
                alertMessage = "Fehler beim Aktualisieren: \(error.localizedDescription)"
                showAlert = true
                return
            }
        }

        let orderId = UUID().uuidString

        let newOrder: [String: Any] = [
            "id": orderId,
            "patientId": selectedPatient.uid ?? "",
            "patientName": displayName.isEmpty ? (selectedPatient.email ?? "Unbekannter Patient") : displayName,
            "description": descriptionText,
            "createdAt": FieldValue.serverTimestamp(),
            "dueDate": Timestamp(date: dueDate),
            "state": "offen",
            "createdBy": creatorUID,
            "assignedTo": "",
            "employeeId": "",
            "notes": []
        ]

        do {
            try await db.collection("orders").document(orderId).setData(newOrder)
            let order = Order(
                id: orderId,
                state: .offen,
                notes: [],
                description: descriptionText,
                patientId: selectedPatient.uid,
                patientName: displayName,
                createdBy: creatorUID,
                assignedTo: nil,
                employeeId: nil,
                dueDate: Timestamp(date: dueDate),
                createdAt: Timestamp(date: Date())
            )
            appState.orders.append(order)
            alertMessage = "Auftrag erfolgreich erstellt."
            showAlert = true
            isPresented = false
        } catch {
            alertMessage = "Fehler beim Speichern: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    NewOrderSheet(isPresented: .constant(true))
        .environmentObject(AppStateViewModel())
}
