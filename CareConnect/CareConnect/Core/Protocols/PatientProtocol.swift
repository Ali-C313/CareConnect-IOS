//
//  PatientProtocol.swift
//  CareConnect
//
//  Created by Ali Chehab on 31.10.25.
//

import Foundation

protocol PatientProtocol {
    /// Patient laden
    func fetch(by id: String) async throws -> Patient
    /// Patienten laden
    func fetchAll() async throws -> [Patient]
}
