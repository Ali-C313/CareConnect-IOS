//
//  MockMedicineRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Medikamente aus den Beispieldaten
final class MockMedicineRepository: MedicineRepository {
    private var medicines = MockData.medicines

    func listen(orgId: String, patientId: String, onChange: @escaping ([MedicineEntry]) -> Void) -> ListenerHandle {
        onChange(medicines)
        return MockListener()
    }

    func add(_ medicine: MedicineEntry, orgId: String, patientId: String) async throws {
        var entry = medicine
        entry.id = UUID().uuidString
        medicines.append(entry)
    }

    func delete(id: String, orgId: String, patientId: String) async throws {
        medicines.removeAll { $0.id == id }
    }
}
