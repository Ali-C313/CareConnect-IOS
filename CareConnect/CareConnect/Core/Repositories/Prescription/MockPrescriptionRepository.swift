//
//  MockPrescriptionRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Verordnungen aus den Beispieldaten
final class MockPrescriptionRepository: PrescriptionRepository {
    private var prescriptions = MockData.prescriptions
    private var links: [LinkedOrg] = []

    func listenAll(orgId: String, onChange: @escaping ([Prescription]) -> Void) -> ListenerHandle {
        onChange(prescriptions)
        return MockListener()
    }

    func create(_ prescription: Prescription) async throws {
        prescriptions.append(prescription)
    }

    func updateStatus(_ prescription: Prescription, status: PrescriptionStatus, orderId: String?) async throws {
        guard let index = prescriptions.firstIndex(where: { $0.id == prescription.id }) else { return }
        prescriptions[index].status = status
        prescriptions[index].orderId = orderId ?? ""
    }

    func withdraw(_ prescription: Prescription) async throws {
        prescriptions.removeAll { $0.id == prescription.id }
    }

    // Freigaben des Patienten
    func listenLinkedOrgs(orgId: String, patientId: String, onChange: @escaping ([LinkedOrg]) -> Void) -> ListenerHandle {
        onChange(links)
        return MockListener()
    }

    func setLinkedOrgs(_ links: [LinkedOrg], orgId: String, patientId: String) async throws {
        self.links = links
    }
}
