//
//  MedicineViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Eigene Medikamente des Patienten
@MainActor
@Observable
final class MedicineViewModel {
    private(set) var medicines: [MedicineEntry] = []
    var errorMessage: String?

    private let container: AppContainer
    private var listener: ListenerHandle?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    private var patientId: String? { container.auth.currentUserId }

    func entries(for time: TimeOfDay) -> [MedicineEntry] {
        medicines.filter { $0.timeOfDay == time }
    }

    func startListening() {
        guard listener == nil, let patientId, let orgId = container.currentOrgId else { return }
        listener = container.medicines.listen(orgId: orgId, patientId: patientId) { [weak self] list in
            self?.medicines = list
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func addMedicine(name: String, dosage: String, timeOfDay: TimeOfDay) {
        guard let patientId else { return }
        let entry = MedicineEntry(name: name.trimmed, dosage: dosage.trimmed, timeOfDay: timeOfDay)
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.medicines.add(entry, orgId: orgId, patientId: patientId)
            } catch {
                errorMessage = tr("Fehler beim Speichern: {0}", error.localizedDescription)
            }
        }
    }

    func deleteMedicine(_ medicine: MedicineEntry) {
        guard let patientId, let id = medicine.id else { return }
        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.medicines.delete(id: id, orgId: orgId, patientId: patientId)
            } catch {
                errorMessage = tr("Löschen fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }
}
