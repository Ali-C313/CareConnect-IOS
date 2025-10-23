//
//  EmployeeCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
import FirebaseAuth

// MARK: - Mitarbeiterkarte
struct EmployeeCard: View {
    let employee: Employee
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(employee.staffStatusEnum.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(employee.staffStatusEnum.color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(employee.firstName) \(employee.lastName)")
                    .bold()
                    .foregroundColor(CCDesign.textPrimary)
                    .lineLimit(1)
                Text(employee.role)
                    .font(.subheadline)
                    .foregroundColor(CCDesign.textSecondary)
                Text(employee.staffStatusEnum.rawValue)
                    .font(.caption2)
                    .foregroundColor(employee.staffStatusEnum.color)
            }
            Spacer()
        }
        .padding()
        .background(CCDesign.card)
        .cornerRadius(16)
        .shadow(color: Color(.separator).opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

