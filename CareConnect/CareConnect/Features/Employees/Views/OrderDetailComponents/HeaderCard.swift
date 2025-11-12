//
//  HeaderCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 12.11.25.
//

import SwiftUI
import FirebaseFirestore

struct HeaderCard: View {
    let order: Order
    @EnvironmentObject var appState: AppStateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Patientenauftrag")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(order.patientName ?? "Unbekannter Patient")
                .font(.title2)
                .fontWeight(.semibold)

            if !order.description.isEmpty {
                Text(order.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            if let patient = appState.patients.first(where: { ($0.uid ?? "") == (order.patientId ?? "") }) {
                if let birthDate = (patient.birthDate as? Date) ?? (patient.birthDate as? Timestamp)?.dateValue() {
                    Text("Geboren: \(birthDate.formatted(date: .abbreviated, time: .omitted)) • \(calculateAge(from: birthDate)) Jahre")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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

    private func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
}

#Preview {
    Text("HeaderCard Preview")
        .foregroundColor(.secondary)
}
