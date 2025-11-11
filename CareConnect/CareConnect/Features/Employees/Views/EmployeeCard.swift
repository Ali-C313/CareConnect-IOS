//
//  EmployeeCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct EmployeeCard: View {
    /// Mitarbeiterdaten
    let employee: Employee
    
    /// UI-Inhalt
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(CCDesign.card.opacity(0.8))
                    .overlay(
                        Circle()
                            .stroke(employee.staffStatusEnum.color, lineWidth: 2)
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: employee.staffStatusEnum.color.opacity(0.25), radius: 4, x: 0, y: 2)

                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(employee.staffStatusEnum.color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(employee.firstName) \(employee.lastName)")
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)

                Text(employee.role)
                    .font(.subheadline)
                    .foregroundColor(CCDesign.textSecondary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(employee.staffStatusEnum.color)
                        .frame(width: 8, height: 8)
                    Text(employee.staffStatusEnum.rawValue)
                        .font(.caption)
                        .foregroundColor(employee.staffStatusEnum.color)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(CCDesign.card)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
