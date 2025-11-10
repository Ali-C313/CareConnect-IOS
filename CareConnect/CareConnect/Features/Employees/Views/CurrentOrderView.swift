//
//  CurrentOrderView.swift
//  CareConnect
//
//  Created by Ali Chehab on 19.10.25.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import MapKit

struct CurrentOrderView: View {
    /// Auftragsdaten
    let order: Order
    /// Patientendaten
    @State private var patient: Patient?
    /// Mitarbeiterdaten
    @State private var employee: Employee?
    /// Ladezustand
    @State private var isLoading = true
    /// Firebase-Service
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
                                AvatarView(initials: initials(from: "\(emp.firstName) \(emp.lastName)"), size: 64)
                                Text("\(emp.firstName) \(emp.lastName)")
                                    .foregroundColor(.white)
                            }
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .foregroundColor(.white)
                            VStack {
                                AvatarView(initials: initials(from: "\(pat.firstName) \(pat.lastName)"), size: 64)
                                Text("\(pat.firstName) \(pat.lastName)")
                                    .foregroundColor(.white)
                            }
                        }
                        Divider().background(.white.opacity(0.2))
                        
                        // Bemerkungen
                        Text("📝 Bemerkungen:")
                            .foregroundColor(.red)
                            .bold()
                        Text(order.notes?.joined(separator: ", ") ?? "Keine Bemerkungen vorhanden.")
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider().background(.white.opacity(0.2))
                        
                        // Standort
                        Text("📍 Standort:")
                            .foregroundColor(.red)
                            .bold()
                        
                        let address = [pat.address, pat.city].compactMap { $0 }.joined(separator: ", ")
                        if address.isEmpty {
                            Text("Keine Adresse verfügbar")
                                .foregroundColor(.white)
                        } else {
                            AddressMapView(address: address, title: "\(pat.firstName) \(pat.lastName)")
                        }
                        
                        Divider().background(.white.opacity(0.2))
                        
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
    
    /// Daten laden
    private func loadDetails() async {
        do {
            async let allPatients = service.fetchPatients()
            async let allEmployees = service.fetchEmployees()
            
            let (patients, employees) = try await (allPatients, allEmployees)
            self.patient = patients.first(where: { patient in
                let uidMatch = (patient.uid ?? "") == (order.assignedTo ?? "")
                let fullName = ((patient.firstName ?? "") + " " + (patient.lastName ?? "")).trimmingCharacters(in: .whitespaces).lowercased()
                let email = (patient.email ?? "").lowercased()
                let target = order.patientName.lowercased()
                return uidMatch || fullName == target || email == target
            })
            self.employee = employees.first(where: { employee in
                (employee.id ?? "") == (order.assignedTo ?? "")
            })
        } catch {
            print("❌ Fehler beim Laden der Order-Details:", error.localizedDescription)
        }
        isLoading = false
    }
    
    /// Initialen bilden
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initialChars = parts.prefix(2).compactMap { $0.first }
        return String(initialChars)
    }
}

#Preview {
    // Beispielvorschau
    let exampleOrder = Order(
        state: .aktuell,
        notes: ["Blutdruck kontrollieren und Medikamente auffüllen."],
        description: "Blutdruck Kontrolle & Medikamente",
        patientName: "Berta Musterfrau",
        createdBy: "TestUser123",
        assignedTo: nil,
        dueDate: Timestamp(date: Date().addingTimeInterval(3600)),
        createdAt: Timestamp(date: Date())
    )
    CurrentOrderView(order: exampleOrder)
        .preferredColorScheme(.dark)
        .background(Color.black)
}