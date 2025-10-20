//
//  Order.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation

enum OrderState: String, Codable, CaseIterable, Identifiable {
    
    case aktuell = "Aktuell"
    case offen = "Offen"
    case erledigt = "Erledigt"
    
    var id: String { rawValue }
}

struct DocumentFile: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fileName: String
}

struct Order: Identifiable, Codable {
    var id: String = UUID().uuidString
    var employeeId: String
    var patientId: String
    var notes: String?
    var state: OrderState
    var documentFiles: [DocumentFile] = []
}
