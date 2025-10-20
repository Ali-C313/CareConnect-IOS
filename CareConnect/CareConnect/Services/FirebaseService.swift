//
//  FirebaseService.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol FirebaseServiceType {
    func fetchEmployees() async throws -> [Employee]
    func fetchPatients() async throws -> [Patient]
    func fetchOrders() async throws -> [Order]
}

final class FirebaseLiveService: FirebaseServiceType {
    private let dataBase = Firestore.firestore()
    private var employeesRef: CollectionReference { dataBase.collection("employees") }
    private var patientsRef: CollectionReference { dataBase.collection("patients") }
    private var ordersRef: CollectionReference { dataBase.collection("orders") }

    func fetchEmployees() async throws -> [Employee] {
        let s = try await employeesRef.getDocuments()
        return try s.documents.map { try $0.data(as: Employee.self) }
    }
    func fetchPatients() async throws -> [Patient] {
        let s = try await patientsRef.getDocuments()
        return try s.documents.map { try $0.data(as: Patient.self) }
    }
    func fetchOrders() async throws -> [Order] {
        let s = try await ordersRef.getDocuments()
        return try s.documents.map { try $0.data(as: Order.self) }
    }
}

// Mock-Daten
final class FirebaseMockService: FirebaseServiceType {
    func fetchEmployees() async throws -> [Employee] {
        [
            Employee(name: "Alex Meyer", age: 35, role: "CEO CareConnect", yearsInCompany: 3.0, status: .available),
            Employee(name: "Olga Petrow", age: 28, role: "", yearsInCompany: 1.5, status: .busy),
            Employee(name: "Sarah Müller", age: 22, role: "", yearsInCompany: 1.0, status: .offline),
            Employee(name: "Julia Braun", age: 32, role: "", yearsInCompany: 2.5, status: .available),
            Employee(name: "Sarah Lang", age: 24, role: "", yearsInCompany: 1.0, status: .busy),
        ]
    }
    func fetchPatients() async throws -> [Patient] {
        let meds1 = [Medication(name: "Herztabletten"), Medication(name: "Knochen Tabletten")]
        let meds2 = [Medication(name: "Candesartan"), Medication(name: "ASS"), Medication(name: "Novalgin")]
        let emergency = EmergencyContact(name: "Nina Landmann", relation: "Enkelin", phone: nil, email: nil, address: nil, age: 35)
        return [
            Patient(name: "Berta Landmann", age: 88, city: "Berlin Kreuzberg", address: "Legiendamm 16", medications: meds1, history: [], emergency: emergency),
            Patient(name: "Berta Landmann", age: 88, city: "Berlin Kreuzberg", address: "Legiendamm 16", medications: meds2, history: ["30.04.2024 Pflegempfängerin hat Ehemann verloren, 40 Jahre Ehe", "Diabetes Typ 2 , Pflegegrad 3, Wassereinlagerung , ATS Strümpfe , Schlaganfall , Halbseiten gelähmt"]),
        ]
    }
    func fetchOrders() async throws -> [Order] {
        let doc1 = DocumentFile(fileName: "Medikamente-Berta-Landmann.pdf")
        let doc2 = DocumentFile(fileName: "Bericht-1.pdf")
        let doc3 = DocumentFile(fileName: "Bericht-2.pdf")
        return [
            Order(employeeId: "emp_sarah_mueller", patientId: "pat_berta", notes: "Bemerkungen: —", state: .aktuell, documentFiles: [doc1, doc2, doc3])
        ]
    }
}
