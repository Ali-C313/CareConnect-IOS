//
//  PatientTabView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct PatientTabView: View {
    @EnvironmentObject var appState: AppStateViewModel
    /// Tab-Ansicht
    var body: some View {
        TabView {
            NavigationStack { PatientHomeView() }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NavigationStack { PatientOrdersView() }
                .tabItem {
                    Label("Aufträge", systemImage: "staroflife.fill")
                }

            NavigationStack {
                PatientMedicineView(patientId: appState.currentUser?.uid ?? "")
            }
                .tabItem {
                    Label("Medizin", systemImage: "cross.case.fill")
                }

            NavigationStack { PatientAppointmentsView() }
                .tabItem {
                    Label("Termine", systemImage: "calendar.badge.plus")
                }

            NavigationStack { PatientSettingsView() }
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
        }
        .accentColor(CCDesign.accent)
        .background(CCDesign.background.ignoresSafeArea())
        .tint(CCDesign.accent)
    }
}

#Preview {
    PatientTabView()
        .environmentObject(AppStateViewModel())
}
