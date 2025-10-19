//
//  EmployeesListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct EmployeesListView: View {
    @StateObject private var vm = EmployeesViewModel()

    var body: some View {
        List(vm.employees) { emp in
            HStack(spacing: 12) {
                AvatarView(initials: initials(from: emp.name), size: 44)
                VStack(alignment: .leading) {
                    Text(emp.name).bold()
                    Text("\(emp.role.isEmpty ? "" : emp.role + ", ")\(emp.age) Jahre")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text("Seit \(String(format: "%.1f", emp.yearsInCompany)) Jahre im Unternehmen!")
                        .font(.footnote).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "person.2.fill").foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .navigationTitle("Mitarbeiter")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}
#Preview {
    EmployeesListView()
}
