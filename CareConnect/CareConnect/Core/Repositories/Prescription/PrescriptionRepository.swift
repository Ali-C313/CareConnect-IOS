//
//  PrescriptionRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

protocol PrescriptionRepository {
    /// Eingehende und ausgehende Verordnungen der Organisation
    func listenAll(orgId: String, onChange: @escaping ([Prescription]) -> Void) -> ListenerHandle
    /// Legt die Verordnung bei Praxis und Pflegedienst an
    func create(_ prescription: Prescription) async throws
    func updateStatus(_ prescription: Prescription, status: PrescriptionStatus, orderId: String?) async throws
    func withdraw(_ prescription: Prescription) async throws

    // Freigaben des Patienten in einer Organisation
    func listenLinkedOrgs(orgId: String, patientId: String, onChange: @escaping ([LinkedOrg]) -> Void) -> ListenerHandle
    func setLinkedOrgs(_ links: [LinkedOrg], orgId: String, patientId: String) async throws
}
