//
//  PatientCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 12.11.25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct PatientCard: View {
    let patient: Patient

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Patientendaten")
                    .font(.headline)
            } icon: {
                Image(systemName: "person.fill")
                    .foregroundColor(.accentColor)
            }

            Text("\(patient.firstName ?? "") \(patient.lastName ?? "")")
                .font(.title3)
                .fontWeight(.semibold)

            if let address = patient.address, !address.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            openInMaps(address: address)
                        } label: {
                            Label("In Karten öffnen", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.subheadline)
                        }
                    }
                }
            }

            if let phone = patient.phone, !phone.isEmpty {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(phone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let allergies = patient.allergies, !allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(allergies)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let birthDate = (patient.birthDate as? Date) ?? (patient.birthDate as? Timestamp)?.dateValue() {
                let age = calculateAge(from: birthDate)
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text("Geboren: \(birthDate.formatted(date: .abbreviated, time: .omitted)) • \(age) Jahre")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }

    private func openInMaps(address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    private func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date, to: Date())
        return components.year ?? 0
    }
}

#Preview {
    let samplePatient = Patient(
        uid: "1",
        firstName: "Max",
        lastName: "Muster",
        address: "Musterstraße 12, 12345 Berlin",
        phone: "0123 456789",
        allergies: "Penicillin",
        birthDate: Timestamp(date: Date())
    )
    PatientCard(patient: samplePatient)
}
