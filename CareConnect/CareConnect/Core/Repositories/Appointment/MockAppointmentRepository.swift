//
//  MockAppointmentRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Termine aus den Beispieldaten
final class MockAppointmentRepository: AppointmentRepository {
    private var appointments = MockData.appointments

    func listen(orgId: String, patientId: String, onChange: @escaping ([AppointmentEntry]) -> Void) -> ListenerHandle {
        onChange(appointments)
        return MockListener()
    }

    func save(_ appointment: AppointmentEntry, orgId: String, patientId: String) async throws {
        if let index = appointments.firstIndex(where: { $0.id != nil && $0.id == appointment.id }) {
            appointments[index] = appointment
        } else {
            var entry = appointment
            entry.id = UUID().uuidString
            appointments.append(entry)
        }
    }

    func delete(id: String, orgId: String, patientId: String) async throws {
        appointments.removeAll { $0.id == id }
    }
}
