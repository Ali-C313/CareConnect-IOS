//
//  GlobalSearchView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Suche über Mitarbeiter, Patienten und Aufträge
struct GlobalSearchView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var searchText = ""

    private var query: String { searchText.trimmed.lowercased() }

    private var employees: [Employee] {
        guard !query.isEmpty else { return appState.employees }
        return appState.employees.filter { "\($0.name) \($0.role ?? "")".lowercased().contains(query) }
    }

    private var patients: [Patient] {
        guard !query.isEmpty else { return appState.patients }
        return appState.patients.filter { "\($0.name) \($0.fullAddress)".lowercased().contains(query) }
    }

    private var orders: [Order] {
        guard !query.isEmpty else { return appState.orders }
        return appState.orders.filter {
            "\($0.patientName ?? "") \($0.description) \($0.notesText)".lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            Section(tr("Mitarbeiter")) {
                ForEach(employees) { employee in
                    NavigationLink {
                        EmployeeProfileView(employeeId: employee.id ?? "")
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(initials: employee.initials, imageURL: employee.profileImageURL, size: 32)
                            VStack(alignment: .leading) {
                                Text(employee.name).fontWeight(.bold)
                                Text(tr(employee.role ?? "")).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            Section(tr("Patienten")) {
                ForEach(patients) { patient in
                    NavigationLink {
                        PatientProfileView(patientId: patient.id ?? "")
                    } label: {
                        Label(patient.name, systemImage: "person.fill")
                    }
                }
            }
            Section(tr("Aufträge")) {
                ForEach(orders) { order in
                    NavigationLink {
                        OrderDetailView(orderId: order.id)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(tr("Auftrag: {0}", order.displayPatientName)).fontWeight(.bold)
                            Text(order.description).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: tr("Suche Mitarbeiter, Patienten, Aufträge…"))
        .navigationTitle(tr("Suche"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { GlobalSearchView() }
        .environment(AppStateViewModel())
}
