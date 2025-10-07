//
//  Auftrag.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import Foundation

enum AuftragStatus: String, CaseIterable {
    case aktuell = "Aktuell"
    case offen = "Offen"
    case erledigt = "Erledigt"
}

struct Auftrag: Identifiable {
    let id = UUID()
    var titel: String
    var beschreibung: String
    var ort: String
    var status: AuftragStatus
    var patient: Patient
    var mitarbeiter: Mitarbeiter?
}
