//
//  PatientsListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct PatientsListView: View {
    /// ViewModel
    @StateObject private var vm = PatientsViewModel()

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()

                let isLoading = vm.isLoading
                if isLoading {
                    ProgressView("Lade Patienten…")
                        .tint(.accentColor)
                } else if vm.patients.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Keine Patienten gefunden")
                            .foregroundColor(.secondary)
                    }
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
