//
//  PatientAppointmentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation

struct PatientAppointmentsView: View {
    /// Terminliste
    @State private var appointments = [
        "Hausbesuch Dr. Müller – 25.10. um 10:00 Uhr",
        "Pflegekontrolle – 27.10. um 15:00 Uhr"
    ]
    @State private var showAddSheet = false
    @StateObject private var appointmentsVM = AppointmentsViewModel()

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            List(appointments, id: \.self) { appointment in
                Label(appointment, systemImage: "calendar")
            }
            .navigationTitle("Termine")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddSheet = true }
                    label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .sheet(isPresented: $showAddSheet) {
                        AddEditAppointmentSheet(viewModel: appointmentsVM)
                    }
                }
            }
        }
    }
}

#Preview {
    PatientAppointmentsView()
}
