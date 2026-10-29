//
//  MedicineRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Medikamente eines Patienten
protocol MedicineRepository {
    func listen(orgId: String, patientId: String, onChange: @escaping ([MedicineEntry]) -> Void) -> ListenerHandle
    func add(_ medicine: MedicineEntry, orgId: String, patientId: String) async throws
    func delete(id: String, orgId: String, patientId: String) async throws
}
