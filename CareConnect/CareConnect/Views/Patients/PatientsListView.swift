//
//  PatientsListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct PatientsListView: View {
    @StateObject private var vm = PatientsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                if vm.patients.isEmpty {
                    ProgressView("Lade Patienten…").tint(.accentColor)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.patients) { patient in
                                NavigationLink {
                                    PatientProfileView(patientId: patient.id ?? "")
                                } label: {
                                    PatientCardView(patient: patient)
                                        .background(CCDesign.card)
                                        .cornerRadius(16)
                                        .shadow(color: Color(.separator).opacity(0.4), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Patienten")
            .task { await vm.load() }
        }
    }
}

#Preview {
    PatientsListView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
