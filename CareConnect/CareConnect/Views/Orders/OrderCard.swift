//
//  OrderCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI

// MARK: - Einzelne Auftrag-Karte
struct OrderCard: View {
    let order: Order
    
    @EnvironmentObject var appState: AppStateViewModel
    
    var patientName: String {
        if let patient = appState.patients.first(where: { $0.id == order.patientId }) {
            return "\(patient.firstName) \(patient.lastName)"
        }
        return "Unbekannter Patient"
    }
    
    var employeeName: String {
        if let employee = appState.employees.first(where: { $0.id == order.employeeId }) {
            return "\(employee.firstName) \(employee.lastName)"
        } else if order.employeeId.isEmpty {
            return "Noch offen"
        }
        return order.employeeId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Kopfzeile
            HStack {
                Text("📋 \(patientName)")
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)
                
                Spacer()
                
                Text(order.state.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(order.state.color.opacity(0.15))
                    .foregroundColor(order.state.color)
                    .cornerRadius(8)
            }
            
            // MARK: - Auftragsnotizen
            if let notes = order.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(CCDesign.textSecondary)
                    .lineLimit(2)
            } else {
                Text("Keine Notizen vorhanden.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // MARK: - Mitarbeiter
            HStack {
                Text("👤 \(employeeName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(CCDesign.card)
        .cornerRadius(16)
        .shadow(color: Color(.separator).opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

