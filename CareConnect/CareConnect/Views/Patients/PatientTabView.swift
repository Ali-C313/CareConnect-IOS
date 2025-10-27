//
//  PatientTabView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI

struct PatientTabView: View {
    var body: some View {
        TabView {
            PatientHomeView()
                .tabItem { Label("Home", systemImage: "house.fill")
                }
            LiveEmergencyView()
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
