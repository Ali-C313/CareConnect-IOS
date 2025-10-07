//
//  Patient.swift
//  CareConnect
//
//  Created by Ali Chehab on 07.10.25.
//

import Foundation

struct Patient: Identifiable {
    let id = UUID()
    var name: String
    var geburtsjahr: Int
    var adresse: String
    var notfallkontakt: String
}
