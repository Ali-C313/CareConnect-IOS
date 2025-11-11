//
//  OrderDisplayModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.11.25.
//

import Foundation
import CoreLocation

/// Kombiniertes Anzeige-Modell für Aufträge mit Patienten- und Mitarbeiterdaten
struct OrderDisplayModel: Identifiable {
    var id: String
    var description: String
    var state: String
    var createdBy: String
    var patientName: String
    var createdAt: Date?
    var dueDate: Date?
    var employeeLocation: CLLocationCoordinate2D?
    var patientAddress: String
}
