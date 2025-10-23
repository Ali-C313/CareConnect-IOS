//
//  PatientAppointmentsView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI

struct PatientAppointmentsView: View {
    @State private var appointments = [
        "Hausbesuch Dr. Müller – 25.10. um 10:00 Uhr",
        "Pflegekontrolle – 27.10. um 15:00 Uhr"
    ]

    var body: some View {
        NavigationStack {
            List(appointments, id: \.self) { appointment in
                Label(appointment, systemImage: "calendar")
            }
            .navigationTitle("Termine")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { /* neuen Termin hinzufügen */ } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    PatientAppointmentsView()
}
