//
//  Mitarbeiter.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import Foundation

struct Mitarbeiter: Identifiable {
    let id = UUID()
    var vorname: String
    var nachname: String
    var alter: Int
    var status: Status
    var rolle: String
}
