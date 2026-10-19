//
//  PatientRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Patienten einer Organisation
protocol PatientRepository {
    func listenAll(orgId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerHandle
    func listen(orgId: String, id: String, onChange: @escaping (Patient?) -> Void) -> ListenerHandle
    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws
    func saveEmergencyContact(orgId: String, id: String, contact: EmergencyContact) async throws
}
