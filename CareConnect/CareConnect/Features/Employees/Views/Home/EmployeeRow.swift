//
//  EmployeeRow.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Mitarbeiter in der Team-Übersicht
struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: employee.initials,
                imageURL: employee.profileImageURL,
                borderColor: employee.currentStatus.color
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(employee.name).font(.headline).lineLimit(1)
                Text(tr(employee.role ?? ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(employee.currentStatus.displayName)
                    .font(.caption2)
                    .foregroundColor(employee.currentStatus.color)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding()
        .background(CCDesign.cardStyle())
    }
}

#Preview {
    EmployeeRow(employee: Employee(firstName: "Mia", lastName: "Schulz", role: "Pflegekraft"))
        .padding()
        .background(CCDesign.background)
}
