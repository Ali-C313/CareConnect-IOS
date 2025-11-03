//
//  SeedDatabase.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import FirebaseFirestore

final class SeedDatabase {
    private let db = Firestore.firestore()
    private let seededKey = "CareConnect.didSeed.v2"

    /// Daten senden
    func runOnce() async {
        if UserDefaults.standard.bool(forKey: seededKey) { return }

        do {
            try await seedEmployees()
            try await seedPatients()
            try await seedOrders()
            UserDefaults.standard.set(true, forKey: seededKey)
            print("✅ Seed abgeschlossen")
        } catch {
            print("❌ Seed fehlgeschlagen:", error.localizedDescription)
        }
    }

    private var employeesRef: CollectionReference { db.collection("employees") }
    private var patientsRef: CollectionReference { db.collection("patients") }
    private var ordersRef: CollectionReference { db.collection("orders") }

    // MARK: - Employees

    /// Erstellt Beispiel-Mitarbeiter in Firestore.
    private func seedEmployees() async throws {
        let employees: [(id: String, first: String, last: String, role: String, status: String, email: String)] = [
            ("emp_alex_meyer", "Alex", "Meyer", "CEO CareConnect", StaffStatus.available.rawValue, "alex.meyer@careconnect.de"),
            ("emp_olga_petrow", "Olga", "Petrow", "Pflegekraft", StaffStatus.busy.rawValue, "olga.petrow@careconnect.de"),
            ("emp_sarah_mueller", "Sarah", "Müller", "Pflegekraft", StaffStatus.off.rawValue, "sarah.mueller@careconnect.de"),
            ("emp_julia_braun", "Julia", "Braun", "Pflegekraft", StaffStatus.available.rawValue, "julia.braun@careconnect.de"),
            ("emp_sarah_lang", "Sarah", "Lang", "Pflegekraft", StaffStatus.pause.rawValue, "sarah.lang@careconnect.de")
        ]

        for emp in employees {
            let data: [String: Any] = [
                "firstName": emp.first,
                "lastName": emp.last,
                "role": emp.role,
                "status": emp.status,
                "email": emp.email
            ]
            try await employeesRef.document(emp.id).setData(data, merge: true)
        }
        print("✅ Employees seeded")
    }

    // MARK: - Patients

    /// Erstellt Beispiel-Patienten mit Adressen, Medikamenten und Historie in Firestore.
    private func seedPatients() async throws {
        let patients: [(id: String, first: String, last: String, address: String, phone: String, meds: [String], history: [String])] = [
            (
                "pat_berta_landmann",
                "Berta", "Landmann",
                "Legiendamm 16, Berlin Kreuzberg",
                "030123456",
                ["Herztabletten", "Knochen Tabletten"],
                []
            ),
            (
                "pat_beate_keller",
                "Beate", "Keller",
                "Friedrichstraße 1, Berlin Mitte",
                "030987654",
                ["Candesartan", "ASS", "Novalgin"],
                [
                    "30.04.2024 Pflegempfängerin hat Ehemann verloren, 40 Jahre Ehe",
                    "Diabetes Typ 2, Pflegegrad 3, Wassereinlagerung, ATS Strümpfe, Schlaganfall, Halbseiten gelähmt"
                ]
            )
        ]

        for p in patients {
            let medsData = p.meds.map { ["id": UUID().uuidString, "name": $0] }
            let data: [String: Any] = [
                "firstName": p.first,
                "lastName": p.last,
                "address": p.address,
                "phone": p.phone,
                "birthDate": NSNull(),
                "notes": NSNull(),
                "medications": medsData,
                "history": p.history
            ]
            try await patientsRef.document(p.id).setData(data, merge: true)
        }
        print("✅ Patients seeded")
    }

    // MARK: - Orders

    /// Erstellt Beispiel-Aufträge, die Mitarbeiter und Patienten verknüpfen.
    private func seedOrders() async throws {
        let orderDocs: [[String: Any]] = [
            ["id": UUID().uuidString, "fileName": "Medikamente-Berta-Landmann.pdf"],
            ["id": UUID().uuidString, "fileName": "Bericht-1.pdf"],
            ["id": UUID().uuidString, "fileName": "Bericht-2.pdf"]
        ]

        let order: [String: Any] = [
            "employeeId": "emp_sarah_mueller",
            "patientId": "pat_berta_landmann",
            "notes": "Blutdruck kontrollieren und Medikamente auffüllen.",
            "state": OrderState.aktuell.rawValue,
            "documentFiles": orderDocs,
            "date": Date()
        ]

        try await ordersRef.document("ord_current_001").setData(order, merge: true)
        print("✅ Orders seeded")
    }
}
