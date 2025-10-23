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

final class AppContainer: ObservableObject {
    let orderRepository: OrderRepository
    let employeeRepository: EmployeeRepository
    let patientRepository: PatientRepository
    let pdfRepository: PDFStorageRepository

    init() {
        self.orderRepository = FirebaseOrderRepository()
        self.employeeRepository = FirebaseEmployeeRepository()
        self.patientRepository = FirebasePatientRepository()
        self.pdfRepository = FirebasePDFStorageRepository()
    }
}
