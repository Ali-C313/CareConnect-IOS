//
//  PatientProfileSections.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bild, Name, Adresse und Button für den Notfallkontakt
struct ProfileHeaderView: View {
    @Environment(\.openURL) private var openURL
    let patient: Patient
    let onEmergencyTap: () -> Void

    var body: some View {
        SectionCard {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(initials: patient.initials, imageURL: patient.profileImageURL, size: 64)
                VStack(alignment: .leading, spacing: 6) {
                    Text(patient.name).font(.title3.bold())
                    if patient.fullAddress.isEmpty {
                        Text(tr("Keine Adresse angegeben")).foregroundColor(.secondary)
                    } else {
                        // Adresse antippen → Karten-App
                        Button {
                            if let url = Links.mapsSearch(patient.fullAddress) { openURL(url) }
                        } label: {
                            Label(patient.fullAddress, systemImage: "map")
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                Spacer()
                Button(action: onEmergencyTap) {
                    VStack(spacing: 2) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark").font(.title2)
                        Text(tr("Notfall")).font(.caption2)
                    }
                    .foregroundColor(.red)
                }
                .accessibilityLabel(tr("Notfallkontakt anzeigen"))
            }
        }
    }
}

/// Telefon und E-Mail mit Buttons
struct ContactSection: View {
    @Environment(\.openURL) private var openURL
    let patient: Patient

    var body: some View {
        SectionCard(title: tr("Kontakt")) {
            if let phone = patient.phone, !phone.isBlank {
                InfoButtonRow(system: "phone", title: tr("Telefon"), value: phone,
                              buttonTitle: tr("Anrufen"), buttonIcon: "phone.fill") {
                    if let url = Links.phone(phone) { openURL(url) }
                }
            } else {
                InfoRow(system: "phone", title: tr("Telefon"), value: tr("Keine Telefonnummer angegeben"))
            }
            if let email = patient.email, !email.isBlank {
                InfoButtonRow(system: "envelope", title: tr("E-Mail"), value: email,
                              buttonTitle: tr("E-Mail senden"), buttonIcon: "paperplane.fill") {
                    if let url = Links.mail(email) { openURL(url) }
                }
            } else {
                InfoRow(system: "envelope", title: tr("E-Mail"), value: tr("Keine E-Mail-Adresse angegeben"))
            }
        }
    }
}

/// Medikamente, Termine, Allergien, Vorgeschichte und Notizen
struct MedicalSection: View {
    let patient: Patient
    let medicines: [MedicineEntry]
    let appointments: [AppointmentEntry]

    var body: some View {
        if !medicines.isEmpty {
            SectionCard(title: tr("Medikamente"), icon: "pills", iconColor: .purple) {
                ForEach(medicines) { medicine in
                    Text("• \(medicine.name) – \(medicine.dosage) (\(medicine.timeOfDay.displayName))")
                }
            }
        } else if let medications = patient.medications, !medications.isEmpty {
            // Alte Einträge direkt am Patienten
            SectionCard(title: tr("Medikamente"), icon: "pills", iconColor: .purple) {
                ForEach(medications, id: \.self) { medication in
                    Text("• \(medication.name)")
                }
            }
        }
        if !appointments.isEmpty {
            SectionCard(title: tr("Nächste Termine"), icon: "calendar") {
                ForEach(appointments.prefix(3)) { appointment in
                    Text("• \(appointment.date.formattedDateTime) – \(appointment.what)")
                }
            }
        }
        if let allergies = patient.allergies, !allergies.isBlank {
            SectionCard(title: tr("Allergien"), icon: "exclamationmark.triangle", iconColor: .orange) {
                Text(allergies)
            }
        }
        if let medicalHistory = patient.medicalHistory, !medicalHistory.isBlank {
            SectionCard(title: tr("Medizinische Vorgeschichte"), icon: "heart", iconColor: .red) {
                Text(medicalHistory)
            }
        }
        if let history = patient.history, !history.isEmpty {
            SectionCard(title: tr("Historie"), icon: "clock.arrow.circlepath") {
                ForEach(history, id: \.self) { entry in
                    Text("• \(entry)")
                }
            }
        }
        if let birthDate = patient.birthDate {
            SectionCard(title: tr("Geburtsdatum"), icon: "birthday.cake") {
                InfoRow(system: "birthday.cake", title: tr("Geboren am"), value: birthDate.formattedDate)
                InfoRow(system: "number", title: tr("Alter"), value: tr("{0} Jahre", birthDate.ageYears))
            }
        }
        if let notes = patient.notes, !notes.isBlank {
            SectionCard(title: tr("Notizen"), icon: "note.text") {
                Text(notes)
            }
        }
    }
}
