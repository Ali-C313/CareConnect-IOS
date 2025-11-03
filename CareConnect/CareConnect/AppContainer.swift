//
//  AppContainer.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

/// App-Abhängigkeitscontainer
final class AppContainer: ObservableObject {
    /// Auftrags-Repo
    let orderRepository: OrderProtocol
    /// Mitarbeiter-Repo
    let employeeRepository: EmployeeProtocol
    /// Patienten-Repo
    let patientRepository: PatientProtocol
    /// PDF-Repo
    let pdfRepository: PDFStorageProtocol

    /// Initialisiert Repos
    init() {
        self.orderRepository = FirebaseOrderRepository()
        self.employeeRepository = FirebaseEmployeeRepository()
        self.patientRepository = FirebasePatientRepository()
        self.pdfRepository = FirebasePDFStorageRepository()
    }
}
