//
//  ContentView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct MainTabView: View {
    /// Tab-Ansicht
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            NavigationStack { PatientsListView() }
                .tabItem {
                    Label("Patienten", systemImage: "person.3.fill")
                }
            
            NavigationStack { OrdersView() }
                .tabItem {
                    Label("Aufträge", systemImage: "doc.text.fill")
                }
            
            NavigationStack { EmployeeSettingsView() }
                .tabItem {
                    Label("Einstellungen", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStateViewModel())
}
