//
//  PatientMedicineView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation

struct PatientMedicineView: View {
    @StateObject private var viewModel = MedicineViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    Section(time.rawValue) {
                        let filtered = viewModel.medicines.filter { $0.timeOfDay == time }
                        if filtered.isEmpty {
                            Text("Keine Medikamente eingetragen.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(filtered) { med in
                                Label("\(med.name) – \(med.dosage)", systemImage: "pills.fill")
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteMedicine(med)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medikamente")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddMedicineSheet(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    PatientMedicineView()
}
