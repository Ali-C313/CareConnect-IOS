//
//  MainTabView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Tabs für Mitarbeiter
struct MainTabView: View {
    @Environment(AppStateViewModel.self) private var appState

    // Praxis und Klinik machen Hausbesuche statt Pflegeaufträge
    private var ordersTitle: String {
        appState.membership?.orgType == .pflegedienst ? tr("Aufträge") : tr("Hausbesuche")
    }

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label(tr("Home"), systemImage: "house.fill") }

            NavigationStack { OrdersView() }
                .tabItem { Label(ordersTitle, systemImage: "doc.text.fill") }

            NavigationStack { PrescriptionsView() }
                .tabItem { Label(tr("Verordnungen"), systemImage: "list.clipboard.fill") }

            NavigationStack { PatientsListView() }
                .tabItem { Label(tr("Patienten"), systemImage: "person.3.fill") }

            NavigationStack { EmployeeSettingsView() }
                .tabItem { Label(tr("Einstellungen"), systemImage: "gearshape.fill") }
        }
        .tint(CCDesign.accent)
    }
}

#Preview {
    MainTabView()
        .environment(AppStateViewModel())
}
