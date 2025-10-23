//
//  PatientMedicineView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI

struct PatientMedicineView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Morgens") {
                    Label("Ibuprofen 400 mg – 1 Tablette", systemImage: "pills.fill")
                    Label("Vitamin D – 1 Kapsel", systemImage: "capsule.fill")
                }
                Section("Abends") {
                    Label("Paracetamol 500 mg – 1 Tablette bei Bedarf", systemImage: "pills.fill")
                }
            }
            .navigationTitle("Medizin")
        }
    }
}

#Preview {
    PatientMedicineView()
}
