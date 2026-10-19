//
//  EmployeeProfileHeaderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bild, Name, Rolle, E-Mail und Status
struct EmployeeProfileHeaderView: View {
    let employee: Employee

    var body: some View {
        SectionCard {
            HStack(spacing: 16) {
                AvatarView(initials: employee.initials, imageURL: employee.profileImageURL, size: 72,
                           borderColor: employee.currentStatus.color)
                VStack(alignment: .leading, spacing: 4) {
                    Text(employee.name.ifBlank("—")).font(.title3.bold())
                    Text(tr((employee.role ?? "").ifBlank("—"))).foregroundColor(.secondary)
                    Text((employee.email ?? "").ifBlank("—"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Label(employee.currentStatus.displayName, systemImage: employee.currentStatus.icon)
                        .font(.caption)
                        .foregroundColor(employee.currentStatus.color)
                    if let birthDate = employee.birthDate {
                        Text(tr("Geboren: {0}", birthDate.formattedDate))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    EmployeeProfileHeaderView(employee: Employee(firstName: "Mia", lastName: "Schulz", role: "Pflegekraft"))
        .padding()
        .screenBackground()
}
