//
//  EmployeesListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI
import Foundation

struct EmployeesListView: View {
    /// ViewModel
    @StateObject private var viewModel = EmployeesViewModel()

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.employees) { employee in
                        NavigationLink(destination: EmployeeProfileView(employeeId: employee.id ?? "")) {
                            HStack(spacing: 14) {
                                if let urlString = employee.profileImageURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 56, height: 56)
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 56, height: 56)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(CCDesign.accent.opacity(0.3), lineWidth: 1)
                                                )
                                        case .failure:
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 56, height: 56)
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
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(employee.firstName) \(employee.lastName)")
                                        .font(.headline)
                                        .foregroundColor(CCDesign.textPrimary)
                                    Text(employee.role)
                                        .font(.subheadline)
                                        .foregroundColor(CCDesign.textSecondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(CCDesign.card))
                            .shadow(color: CCDesign.textSecondary.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .background(CCDesign.background.ignoresSafeArea())
            .navigationTitle("Mitarbeiter")
            .task {
                await viewModel.loadEmployees()
            }
        }
    }
}

#Preview {
    EmployeesListView()
}
