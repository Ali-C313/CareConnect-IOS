//
//  PatientTabView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation

struct PatientTabView: View {
    /// Tab-Ansicht
    var body: some View {
        TabView {
            PatientHomeView()
                .tabItem { Label("Home", systemImage: "house.fill")
                }
            PatientOrdersView()
                .tabItem { Label("Auftrag Status", systemImage: "staroflife.fill")
                }
            PatientMedicineView()
                .tabItem { Label("Medizin", systemImage: "cross.case.fill")
                }
            PatientAppointmentsView()
                .tabItem { Label("Termin", systemImage: "calendar.badge.plus")
                }
            PatientSettingsView()
                .tabItem { Label("Einstellungen", systemImage: "gear")
                }
        }
        .tint(.green)
    }
}

#Preview {
    PatientTabView()
}