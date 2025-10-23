//
//  CurrentOrderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 19.10.25.
//

import SwiftUI

struct CurrentOrderView: View {
    
    let order: Order
    @State private var patient: Patient?
    @State private var employee: Employee?
    @State private var isLoading = true
    
    private let service = FirebaseLiveService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if isLoading {
                    ProgressView("Lade Daten ...")
                        .tint(.accentColor)
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                } else {
                    if let emp = employee, let pat = patient {
                        // Mitarbeiter & Patient Header
                        HStack(spacing: 24) {
                            VStack {
                                AvatarView(initials: initials(from: emp.name), size: 64)
                                Text(emp.name)
                                    .foregroundColor(.white)
                            }
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .foregroundColor(.white)
                            VStack {
                                AvatarView(initials: initials(from: pat.name), size: 64)
                                Text(pat.name)
                                    .foregroundColor(.white)
                            }
                        }
                        Divider().background(.white.opacity(0.2))
                        
                        // Bemerkungen
                        Text("📝 Bemerkungen:")
                            .foregroundColor(.red)
                            .bold()
                        Text(order.notes ?? "Keine Bemerkungen vorhanden.")
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider().background(.white.opacity(0.2))
                        
                        // Standort
                        Text("📍 Standort:")
                            .foregroundColor(.red)
                            .bold()
                        
                        let addr = [pat.address, pat.city].compactMap { $0 }.joined(separator: ", ")
                        AddressMapView(address: addr.isEmpty ? nil : addr, title: pat.name)
                        
                        Divider().background(.white.opacity(0.2))
                        
                        // Dokumente
                        if !order.documentFiles.isEmpty {
                            Text("📄 Dokumente:")
                                .foregroundColor(.red)
                                .bold()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(order.documentFiles) { doc in
                                        PDFCardView(fileName: doc.fileName)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        Text("Fehler: Daten konnten nicht geladen werden.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle(order.displayTitle)
        .task { await loadDetails() }
    }
    
    // MARK: - Lade Patient & Mitarbeiter
    private func loadDetails() async {
        do {
            async let allPatients = service.fetchPatients()
            async let allEmployees = service.fetchEmployees()
            
            let (patients, employees) = try await (allPatients, allEmployees)
            self.patient = patients.first(where: { $0.id == order.patientId })
            self.employee = employees.first(where: { $0.id == order.employeeId })
        } catch {
            print("❌ Fehler beim Laden der Order-Details:", error.localizedDescription)
        }
        isLoading = false
    }
    
    // MARK: - Helper
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}

#Preview {
    // Beispielvorschau
    let exampleOrder = Order(
        employeeId: "emp_sarah_mueller",
        patientId: "pat_berta",
        notes: "Blutdruck kontrollieren und Medikamente auffüllen.",
        state: .aktuell,
        documentFiles: [
            DocumentFile(fileName: "Medikamente.pdf"),
            DocumentFile(fileName: "Bericht-1.pdf")
        ]
    )
    return CurrentOrderView(order: exampleOrder)
        .preferredColorScheme(.dark)
        .background(Color.black)
}
