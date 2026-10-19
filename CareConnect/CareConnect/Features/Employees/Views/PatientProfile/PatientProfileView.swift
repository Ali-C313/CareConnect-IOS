//
//  PatientProfileView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Profil eines Patienten aus Sicht der Mitarbeiter
struct PatientProfileView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var viewModel = PatientProfileViewModel()
    @State private var showContactSheet = false
    @State private var showContactEditor = false

    let patientId: String

    private var patient: Patient? { appState.patient(id: patientId) }

    var body: some View {
        Group {
            if let patient {
                ScrollView {
                    VStack(spacing: 16) {
                        ProfileHeaderView(patient: patient) { showContactSheet = true }
                        ContactSection(patient: patient)
                        MedicalSection(
                            patient: patient,
                            medicines: viewModel.medicines,
                            appointments: viewModel.upcomingAppointments
                        )
                        locationSection(patient)
                    }
                    .padding()
                }
                .onAppear { viewModel.loadCoordinate(address: patient.fullAddress) }
                .onChange(of: patient.fullAddress) { _, newAddress in
                    viewModel.loadCoordinate(address: newAddress)
                }
            } else {
                ContentUnavailableView(
                    tr("Patient nicht gefunden"),
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text(tr("Der Patient ist nicht mehr in dieser Organisation."))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(tr("Profil"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.startListening(patientId: patientId) }
        .onDisappear { viewModel.stopListening() }
        .sheet(isPresented: $showContactSheet) {
            EmergencyContactDetailsView(contact: patient?.emergencyContact) {
                showContactSheet = false
                showContactEditor = true
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showContactEditor) {
            EmergencyContactEditorView(contact: patient?.emergencyContact ?? EmergencyContact()) { contact in
                await viewModel.saveEmergencyContact(contact, patientId: patientId)
            }
        }
        .messageAlert(tr("Fehler"), message: $viewModel.errorMessage)
    }

    private func locationSection(_ patient: Patient) -> some View {
        var markers: [MapMarker] = []
        if let coordinate = viewModel.coordinate {
            markers = [MapMarker(title: patient.name, coordinate: coordinate)]
        }
        let emptyText: String
        if patient.fullAddress.isEmpty {
            emptyText = tr("Keine Adresse angegeben")
        } else if viewModel.isLoadingLocation {
            emptyText = tr("Adresse wird gesucht…")
        } else {
            emptyText = tr("Adresse nicht auf der Karte gefunden")
        }

        return SectionCard(title: tr("Standort"), icon: "map") {
            CareMap(markers: markers, emptyText: emptyText, isLoading: viewModel.isLoadingLocation)
            // Klappt auch, wenn die Karte die Adresse nicht findet
            if !patient.fullAddress.isEmpty {
                Button {
                    if let url = Links.mapsSearch(patient.fullAddress) { openURL(url) }
                } label: {
                    Label(tr("In Karten öffnen"), systemImage: "map")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { PatientProfileView(patientId: "1") }
        .environment(AppStateViewModel())
}
