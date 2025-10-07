//
//  Status.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import Foundation

enum Status: String, CaseIterable, Identifiable {
    case verfügbar = "Verfügbar"
    case imEinsatz = "Im Einsatz"
    case pause = "Pause"
    case krank = "Krank"

    var id: String { rawValue }
}
