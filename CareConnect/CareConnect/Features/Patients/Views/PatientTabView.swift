//
//  PatientTabView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Tabs für Patienten
struct PatientTabView: View {
    enum Tab: Hashable {
        case home, orders, medicine, appointments, settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PatientHomeView { selectedTab = .orders }
            }
            .tabItem { Label(tr("Home"), systemImage: "house.fill") }
            .tag(Tab.home)

            NavigationStack { PatientOrdersView() }
                .tabItem { Label(tr("Aufträge"), systemImage: "cross.case.fill") }
                .tag(Tab.orders)

            NavigationStack { PatientMedicineView() }
                .tabItem { Label(tr("Medizin"), systemImage: "pills.fill") }
                .tag(Tab.medicine)

            NavigationStack { PatientAppointmentsView() }
                .tabItem { Label(tr("Termine"), systemImage: "calendar") }
                .tag(Tab.appointments)

            NavigationStack { PatientSettingsView() }
                .tabItem { Label(tr("Einstellungen"), systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(CCDesign.accent)
    }
}

#Preview {
    PatientTabView()
        .environment(AppStateViewModel())
}
