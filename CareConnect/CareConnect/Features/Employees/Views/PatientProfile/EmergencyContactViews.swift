//
//  EmergencyContactViews.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Notfallkontakt anzeigen
struct EmergencyContactDetailsView: View {
    @Environment(\.openURL) private var openURL
    let contact: EmergencyContact?
    let onEdit: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if let contact, !contact.name.isBlank {
                        SectionCard {
                            InfoRow(system: "person", title: tr("Name"), value: contact.name)
                            if !contact.relation.isBlank {
                                InfoRow(system: "heart", title: tr("Beziehung"), value: contact.relation)
                            }
                            if let age = contact.age {
                                InfoRow(system: "birthday.cake", title: tr("Alter"), value: "\(age)")
                            }
                            linkRow(system: "phone", title: tr("Telefon"), value: contact.phone,
                                    empty: tr("Keine Telefonnummer angegeben"), buttonIcon: "phone.fill",
                                    url: Links.phone(contact.phone))
                            linkRow(system: "envelope", title: tr("E-Mail"), value: contact.email,
                                    empty: tr("Keine E-Mail-Adresse angegeben"), buttonIcon: "paperplane.fill",
                                    url: Links.mail(contact.email))
                            linkRow(system: "mappin", title: tr("Adresse"), value: contact.address,
                                    empty: tr("Keine Adresse angegeben"), buttonIcon: "map",
                                    url: Links.mapsSearch(contact.address))
                        }
                        Button(action: onEdit) {
                            Label(tr("Bearbeiten"), systemImage: "pencil").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text(tr("Kein Notfallkontakt vorhanden."))
                        Button(action: onEdit) {
                            Label(tr("Notfallkontakt hinzufügen"), systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .screenBackground()
            .navigationTitle(tr("Notfallkontakt"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Leerer Wert → nur Text, sonst mit Button
    @ViewBuilder
    private func linkRow(system: String, title: String, value: String, empty: String,
                         buttonIcon: String, url: URL?) -> some View {
        if value.isBlank {
            InfoRow(system: system, title: title, value: empty)
        } else {
            InfoButtonRow(system: system, title: title, value: value, buttonTitle: title, buttonIcon: buttonIcon) {
                if let url { openURL(url) }
            }
        }
    }
}

/// Notfallkontakt anlegen oder bearbeiten
struct EmergencyContactEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contact: EmergencyContact
    @State private var ageText: String
    @State private var isSaving = false

    /// Gibt true zurück, wenn gespeichert wurde
    let onSave: (EmergencyContact) async -> Bool

    init(contact: EmergencyContact, onSave: @escaping (EmergencyContact) async -> Bool) {
        _contact = State(initialValue: contact)
        _ageText = State(initialValue: contact.age.map(String.init) ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(tr("Person")) {
                    TextField(tr("Name"), text: $contact.name)
                    TextField(tr("Beziehung (z. B. Ehepartner)"), text: $contact.relation)
                    TextField(tr("Alter"), text: $ageText)
                        .keyboardType(.numberPad)
                }
                Section(tr("Kontakt")) {
                    TextField(tr("Telefonnummer"), text: $contact.phone)
                        .keyboardType(.phonePad)
                    TextField(tr("E-Mail-Adresse"), text: $contact.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    AddressSearchField(address: $contact.address)
                }
            }
            .navigationTitle(tr("Notfallkontakt"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(tr("Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button(tr("Speichern")) { save() }
                            .disabled(contact.name.isBlank)
                    }
                }
            }
        }
    }

    private func save() {
        contact.age = Int(ageText.filter(\.isNumber))
        isSaving = true
        Task {
            let saved = await onSave(contact)
            isSaving = false
            if saved { dismiss() }
        }
    }
}

#Preview {
    EmergencyContactDetailsView(contact: EmergencyContact(name: "Anna Schmidt", relation: "Tochter", phone: "0176 1234567")) {}
}
