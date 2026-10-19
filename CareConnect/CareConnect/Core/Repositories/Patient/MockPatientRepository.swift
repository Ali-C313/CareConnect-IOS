//
//  MockPatientRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Patienten aus den Beispieldaten
final class MockPatientRepository: PatientRepository {
    private var patients = MockData.patients

    func listenAll(orgId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerHandle {
        onChange(patients)
        return MockListener()
    }

    func listen(orgId: String, id: String, onChange: @escaping (Patient?) -> Void) -> ListenerHandle {
        onChange(patients.first { $0.id == id })
        return MockListener()
    }

    func updateProfile(orgId: String, id: String, fields: [String: Any]) async throws {}

    func saveEmergencyContact(orgId: String, id: String, contact: EmergencyContact) async throws {
        guard let index = patients.firstIndex(where: { $0.id == id }) else { return }
        patients[index].emergencyContact = contact
    }
}
