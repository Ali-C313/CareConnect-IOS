//
//  PatientOrderDisplayModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 10.11.25.
//

import Foundation
import FirebaseFirestore
import Combine
import CoreLocation
import SwiftUI

struct PatientOrderDisplayModel: Identifiable {
    let id: String
    let title: String
    let description: String
    let state: String
    let employeeId: String?
    let patientLatitude: Double?
    let patientLongitude: Double?
    let date: Date
    // Zusatzfelder für die Anzeige
    let employeeName: String
    let employeePhone: String
    let employeeLocation: CLLocationCoordinate2D?
    let etaFormatted: String
    let statusText: String
    let statusColor: Color

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
