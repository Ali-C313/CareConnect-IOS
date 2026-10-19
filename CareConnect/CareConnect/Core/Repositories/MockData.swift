//
//  MockData.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Beispieldaten für die Mock-Repositories und Previews
enum MockData {
    /// Erst anlegen, dann z. B. die Dokument-ID setzen
    private static func make<T>(_ value: T, _ change: (inout T) -> Void) -> T {
        var copy = value
        change(&copy)
        return copy
    }

    static let orgId = "mock-org"
    static let employeeId = "mock-employee"
    static let patientId = "mock-patient"

    static let profile = make(UserProfile(firstName: "Ali", lastName: "Chehab", email: "ali@careconnect.de",
                                          address: "Hauptstraße 1", city: "Berlin", activeOrgId: orgId)) {
        $0.id = employeeId
    }

    static let organization = make(Organization(name: "Pflegedienst Sonnenschein", type: .pflegedienst,
                                                address: "Hauptstraße 1, Berlin", ownerId: employeeId)) {
        $0.id = orgId
    }

    static let membership = make(Membership(orgName: "Pflegedienst Sonnenschein", orgType: .pflegedienst, role: .admin)) {
        $0.orgId = orgId
    }

    static let employees: [Employee] = [
        make(Employee(firstName: "Ali", lastName: "Chehab", role: "Pflegekraft",
                 status: .available, email: "ali@careconnect.de")) { $0.id = employeeId },
        make(Employee(firstName: "Mia", lastName: "Schulz", role: "Pflegekraft",
                 status: .busy, email: "mia@careconnect.de")) { $0.id = "mock-employee-2" }
    ]

    static let patients: [Patient] = [
        make(Patient(firstName: "Maria", lastName: "Schmidt", address: "Gartenweg 5",
                city: "Berlin", phone: "0176 1234567", email: "maria@example.de", allergies: "Penicillin",
                emergencyContact: EmergencyContact(name: "Anna Schmidt", relation: "Tochter", phone: "0176 7654321"))) { $0.id = patientId },
        make(Patient(firstName: "Peter", lastName: "Wagner", address: "Lindenallee 12",
                city: "Berlin", phone: "0151 2223344")) { $0.id = "mock-patient-2" }
    ]

    static let orders: [Order] = [
        make(Order(state: .offen, description: "Verbandswechsel",
              patientId: patientId, patientName: "Maria Schmidt", employeeId: "",
              dueDate: Timestamp(date: Date().addingTimeInterval(3600)), createdAt: Timestamp())) { $0.documentId = "order-1" },
        make(Order(state: .aktuell, description: "Blutdruck messen",
              patientId: "mock-patient-2", patientName: "Peter Wagner", employeeId: employeeId,
              dueDate: Timestamp(), createdAt: Timestamp())) { $0.documentId = "order-2" },
        make(Order(state: .erledigt, description: "Medikamente stellen",
              patientId: patientId, patientName: "Maria Schmidt", employeeId: employeeId,
              createdAt: Timestamp(date: Date().addingTimeInterval(-86400)),
              report: CompletionReport(note: "Wochenbox gestellt", completedByName: "Ali Chehab"))) { $0.documentId = "order-3" }
    ]

    static let medicines: [MedicineEntry] = [
        make(MedicineEntry(name: "Ibuprofen", dosage: "400 mg", timeOfDay: .morning)) { $0.id = "med-1" },
        make(MedicineEntry(name: "Vitamin D", dosage: "1 Tablette", timeOfDay: .evening)) { $0.id = "med-2" }
    ]

    static let appointments: [AppointmentEntry] = [
        make(AppointmentEntry(what: "Hausarzt", address: "Praxis Dr. Weber, Berlin",
                         date: Timestamp(date: Date().addingTimeInterval(2 * 86400)), bringItems: ["Krankenkassenkarte"])) { $0.id = "app-1" }
    ]

    static let prescriptions: [Prescription] = [
        make(Prescription(fromOrgId: "mock-praxis", fromOrgName: "Praxis Dr. Weber",
                     toOrgId: orgId, toOrgName: organization.name, patientId: patientId,
                     patientName: "Maria Schmidt", title: "Verbandswechsel", frequency: "3x pro Woche",
                     startDate: Timestamp())) { $0.id = "pre-1" }
    ]
}
