//
//  PatientsListView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation

struct PatientsListView: View {
    /// ViewModel
    @StateObject private var vm = PatientsViewModel()

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ZStack {
                CCDesign.background.ignoresSafeArea()
                
                if vm.isLoading {
                    VStack(spacing: 12) {
                        ProgressView("Lade Patienten…")
                            .tint(CCDesign.accent)
                            .scaleEffect(1.2)
                        Text("Bitte warten...")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                } else if vm.patients.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("Keine Patienten gefunden")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Neue Patienten erscheinen automatisch, sobald sie hinzugefügt werden.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.patients) { patient in
                                NavigationLink {
                                    PatientProfileView(patientId: patient.id ?? "")
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: "person.fill")
                                            .font(.title2)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                Circle()
                                                    .fill(CCDesign.accent.opacity(0.1))
                                            )
                                            .foregroundColor(CCDesign.accent)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(patient.firstName ?? "") \(patient.lastName ?? "")")
                                                .font(.headline)
                                                .foregroundColor(CCDesign.textPrimary)
                                            Text(patient.address ?? "Keine Adresse vorhanden")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(CCDesign.card)
                                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Patienten")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load() }
        }
    }
}

#Preview {
    PatientsListView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
