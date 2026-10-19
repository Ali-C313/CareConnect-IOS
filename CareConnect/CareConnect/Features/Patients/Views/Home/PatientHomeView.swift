//
//  PatientHomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Startseite für Patienten mit Notruf
struct PatientHomeView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var viewModel = PatientHomeViewModel()
    @State private var showEmergencyDialog = false

    let onOrdersTap: () -> Void

    private var emergencyPhone: String? {
        guard let phone = appState.currentPatient?.emergencyContact?.phone, !phone.isBlank else { return nil }
        return phone
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 140))
                    .foregroundColor(CCDesign.accent)
                Text(tr("Ihre Gesundheit in besten Händen."))
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(tr("Willkommen bei CareConnect – Ihr Partner für eine verlässliche Versorgung."))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                EmergencyButton(showAlert: $showEmergencyDialog)
                    .padding(.top)

                Button(action: onOrdersTap) {
                    Label(tr("Zu meinen Aufträgen"), systemImage: "magnifyingglass")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Text("© 2025 CareConnect")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 24)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .background(
            LinearGradient(colors: [CCDesign.accent.opacity(0.2), CCDesign.background], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle(tr("Home"))
        .confirmationDialog(tr("Notfallaktion"), isPresented: $showEmergencyDialog, titleVisibility: .visible) {
            // 112 steht immer ganz oben
            Button(tr("Notruf 112 anrufen"), role: .destructive) {
                if let url = Links.phone("112") { openURL(url) }
            }
            if let emergencyPhone {
                Button(tr("Notfallkontakt anrufen")) {
                    if let url = Links.phone(emergencyPhone) { openURL(url) }
                }
            }
            Button(tr("Pflegedienst rufen (dringender Auftrag)")) {
                viewModel.createEmergencyOrder(patientName: appState.currentPatient?.name ?? "")
            }
            Button(tr("Abbrechen"), role: .cancel) {}
        } message: {
            Text(tr("Wählen Sie eine Notfallaktion aus:"))
        }
        .messageAlert(tr("Notfall"), message: $viewModel.message)
    }
}

#Preview {
    NavigationStack { PatientHomeView {} }
        .environment(AppStateViewModel())
}
