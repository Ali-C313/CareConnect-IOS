//
//  PatientCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Kontakt, Adresse und medizinische Infos des Patienten
struct PatientCard: View {
    @Environment(\.openURL) private var openURL
    let patient: Patient

    var body: some View {
        SectionCard(title: tr("Patientendaten"), icon: "person") {
            Text(patient.name).font(.title3.weight(.semibold))

            if let phone = patient.phone, !phone.isBlank {
                InfoButtonRow(system: "phone", title: tr("Telefon"), value: phone,
                              buttonTitle: tr("Anrufen"), buttonIcon: "phone.fill") {
                    open(Links.phone(phone))
                }
            }
            if let email = patient.email, !email.isBlank {
                InfoButtonRow(system: "envelope", title: tr("E-Mail"), value: email,
                              buttonTitle: tr("E-Mail senden"), buttonIcon: "paperplane.fill") {
                    open(Links.mail(email))
                }
            }
            if !patient.fullAddress.isEmpty {
                InfoButtonRow(system: "map", title: tr("Adresse"), value: patient.fullAddress,
                              buttonTitle: tr("In Karten öffnen"), buttonIcon: "location.north.line.fill") {
                    open(Links.mapsSearch(patient.fullAddress))
                }
            }
            if let medications = patient.medications, !medications.isEmpty {
                SmallSection(icon: "pills", tint: .purple, title: tr("Medikamente"),
                             text: medications.map { "• \($0.name)" }.joined(separator: "\n"))
            }
            if let allergies = patient.allergies, !allergies.isBlank {
                SmallSection(icon: "exclamationmark.triangle", tint: .orange, title: tr("Allergien"), text: allergies)
            }
            if let history = patient.medicalHistory, !history.isBlank {
                SmallSection(icon: "exclamationmark.triangle", tint: .red, title: tr("Medizinische Vorgeschichte"), text: history)
            }
            if let entries = patient.history, !entries.isEmpty {
                SmallSection(icon: "clock", tint: .secondary, title: tr("Historie"),
                             text: entries.map { "• \($0)" }.joined(separator: "\n"))
            }
        }
    }

    private func open(_ url: URL?) {
        if let url { openURL(url) }
    }
}

/// Kleiner Abschnitt mit Icon, Überschrift und Text
struct SmallSection: View {
    let icon: String
    let tint: Color
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundColor(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(text).font(.subheadline)
            }
        }
    }
}

#Preview {
    PatientCard(patient: Patient(firstName: "Maria", lastName: "Schmidt", address: "Hauptstr. 1",
                                 city: "Berlin", phone: "0176 1234567", allergies: "Penicillin"))
        .padding()
        .screenBackground()
}
