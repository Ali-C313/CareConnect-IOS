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
        ZStack { GradientBackground() }
            .overlay(content)
            .navigationTitle("Patienten")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.load() }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(vm.patients) { patient in
                    NavigationLink { PatientProfileView(patient: patient) } label: {
                        PatientCardView(patient: patient)
                    }
                }
            }.padding(.horizontal).padding(.top, 12)
        }
    }
}

#Preview {
    PatientsListView()
}
