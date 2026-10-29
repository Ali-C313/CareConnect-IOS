//
//  AppointmentRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Termine eines Patienten
protocol AppointmentRepository {
    func listen(orgId: String, patientId: String, onChange: @escaping ([AppointmentEntry]) -> Void) -> ListenerHandle
    /// Ohne ID wird ein neuer Termin angelegt, sonst überschrieben
    func save(_ appointment: AppointmentEntry, orgId: String, patientId: String) async throws
    func delete(id: String, orgId: String, patientId: String) async throws
}
