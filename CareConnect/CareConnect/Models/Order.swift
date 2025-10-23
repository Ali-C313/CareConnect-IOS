//
//  Order.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

enum OrderState: String, Codable, CaseIterable, Identifiable {
    case aktuell  = "Aktuell"
    case offen    = "Offen"
    case erledigt = "Erledigt"

    var id: String { rawValue }
    var displayName: String { rawValue }
    var color: Color {
        switch self {
        case .offen:    return .orange
        case .aktuell:  return .blue
        case .erledigt: return .green
        }
    }
}

struct DocumentFile: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var fileName: String
}

struct Order: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var employeeId: String
    var patientId: String
    var notes: String?
    var state: OrderState
    var documentFiles: [DocumentFile] = []
    var date: Date = Date()

    var isActive: Bool { state == .aktuell }
    var displayTitle: String { "Auftrag #\((id ?? "Unbekannt").prefix(6))" }
}
