//
//  GlobalSearchView.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//


import SwiftUI

struct GlobalSearchView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Mitarbeiter") {
                    ForEach(appState.filteredEmployees(appState.searchText)) { e in
                        HStack(spacing: 12) {
                            AvatarView(initials: "\(e.firstName.prefix(1))\(e.lastName.prefix(1))", size: 32)
                            VStack(alignment: .leading) {
                                Text("\(e.firstName) \(e.lastName)").bold()
                                Text(e.role).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                Section("Patienten") {
                    ForEach(appState.filteredPatients(appState.searchText)) { p in
                        NavigationLink("\(p.firstName) \(p.lastName)") {
                            PatientProfileView(patientId: p.id ?? "")
                        }
                    }
                }
                Section("Aufträge") {
                    ForEach(appState.filteredOrders(appState.searchText)) { o in
                        let title = "Auftrag: \(o.patientName)"
                        NavigationLink(title) {
                            OrderDetailView(order: o).environmentObject(appState)
                        }
                    }
                }
            }
            .navigationTitle("Suche")
            .searchable(text: $appState.searchText)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Schließen"){ dismiss() } } }
        }
    }
}
