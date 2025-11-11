//
//  OrderCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
import Foundation

struct OrderCard: View {
    /// Auftragsdaten
    let order: Order
    
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    
    /// Patientenname
    var patientName: String {
        if let patient = appState.patients.first(where: {
            let emailMatch = (($0.email ?? "").lowercased() == order.patientName.lowercased())
            let fullName = ((($0.firstName ?? "") + " " + ($0.lastName ?? "")).trimmingCharacters(in: .whitespaces)).lowercased()
            let nameMatch = (fullName == order.patientName.lowercased())
            return ($0.uid == order.assignedTo) || emailMatch || nameMatch
        }) {
            let first = patient.firstName ?? ""
            let last = patient.lastName ?? ""
            if !first.isEmpty || !last.isEmpty {
                return "\(first) \(last)"
            }
            return patient.email ?? "Unbekannt"
        }
        let fallback = order.patientName.isEmpty ? "Unbekannt" : order.patientName
        return fallback
    }
    
    /// Mitarbeitername
    var employeeName: String {
        if let employee = appState.employees.first(where: { $0.id == order.assignedTo }) {
            return "\(employee.firstName) \(employee.lastName)"
        } else if (order.assignedTo ?? "").isEmpty {
            return "Noch offen"
        }
        return order.assignedTo ?? ""
    }
    
    /// UI-Inhalt
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
            
            // MARK: - Auftragsbeschreibung
            if !order.description.isEmpty {
                let description = order.description
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(CCDesign.textSecondary)
                    .lineLimit(2)
            } else {
                Text("Keine Beschreibung vorhanden.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // MARK: - Ersteller
            if !order.createdBy.isEmpty {
                let createdBy = order.createdBy
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(CCDesign.accent)
                    Text(createdBy)
                        .font(.caption)
                        .foregroundColor(CCDesign.textSecondary)
                    Spacer()
                }
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
