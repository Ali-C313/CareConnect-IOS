//
//  EditProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State var employee: Employee
    private let service: FirebaseServiceType = FirebaseLiveService()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemein") {
                    TextField("Vorname", text: $employee.firstName)
                    TextField("Nachname", text: $employee.lastName)
                    TextField("Rolle", text: $employee.role)
                    TextField("E-Mail", text: $employee.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .navigationTitle("Profil bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task { await save() }
                    }
                }
            }
        }
    }
    
    private func save() async {
        guard let id = employee.id else { dismiss(); return }
        do {
            try await service.updateEmployee(id: id, fields: [
                "firstName": employee.firstName,
                "lastName": employee.lastName,
                "role": employee.role,
                "email": employee.email
            ])
            dismiss()
        } catch {
            print("❌ Fehler beim Speichern:", error.localizedDescription)
        }
    }
}

#Preview {
    // Beispiel-Demo-Mitarbeiter für Xcode Canvas
    EditProfileView(employee: Employee(
        id: "demo001",
        firstName: "Ali",
        lastName: "Chehab",
        role: "Außendienst",
        status: "Verfügbar",
        email: "ali.chehab@careconnect.de"
    ))
    .preferredColorScheme(.dark)
}
