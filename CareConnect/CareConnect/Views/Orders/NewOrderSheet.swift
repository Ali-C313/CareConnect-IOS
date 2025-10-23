//
//  NewOrderSheet.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
struct NewOrderSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppStateViewModel

    @State private var patientName = ""
    @State private var descriptionText = ""
    @State private var dueDate = Date()
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            Form {
                Section("Patient") {
                    TextField("Name eingeben", text: $patientName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                }

                Section("Beschreibung") {
                    TextField("Beschreibung des Auftrags", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Zeitpunkt") {
                    DatePicker(
                        "Ausführungszeit",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle("Neuer Auftrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task { await saveOrder() }
                    }
                    .disabled(patientName.isEmpty || descriptionText.isEmpty)
                }
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Speichere Auftrag…")
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .alert("Hinweis", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Auftrag speichern
    private func saveOrder() async {
        guard !patientName.isEmpty, !descriptionText.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        // ✅ Zugriff auf deinen angemeldeten Benutzer
        let creatorUID = appState.currentUser?.uid ?? "unbekannt"

        let orderId = UUID().uuidString
        let newOrder: [String: Any] = [
            "id": orderId,
            "patientName": patientName,
            "description": descriptionText,
            "createdAt": Timestamp(date: Date()),
            "dueDate": Timestamp(date: dueDate),
            "state": "offen",
            "createdBy": creatorUID,
            "assignedTo": NSNull(),
            "notes": []
        ]

        do {
            try await db.collection("orders").document(orderId).setData(newOrder)
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
