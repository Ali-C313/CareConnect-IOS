//
//  EmployeesListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct EmployeesListView: View {
    /// ViewModel
    @StateObject private var viewModel = EmployeesViewModel()

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            List(viewModel.employees) { employee in
                NavigationLink {
                    EmployeeProfileView(employeeId: employee.id ?? "")
                } label: {
                    HStack(spacing: 12) {
                        // Profilbild
                        if let urlString = employee.profileImageURL,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 44, height: 44)
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                case .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(employee.firstName) \(employee.lastName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(employee.role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .task {
                await viewModel.loadEmployees()
            }
            .navigationTitle("Mitarbeiter")
        }
    }
}

#Preview {
    EmployeesListView()
}
