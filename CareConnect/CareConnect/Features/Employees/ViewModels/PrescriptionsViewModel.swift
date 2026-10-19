//
//  PrescriptionsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Eingang = an uns geschickt, Ausgang = von uns verschickt
enum PrescriptionDirection: CaseIterable, Identifiable {
    case incoming
    case outgoing

    var id: Self { self }

    var displayName: String {
        switch self {
        case .incoming: return tr("Eingang")
        case .outgoing: return tr("Ausgang")
        }
    }
}

/// Verordnungen senden, übernehmen, ablehnen und zurückziehen
@MainActor
@Observable
final class PrescriptionsViewModel {
    var direction: PrescriptionDirection = .incoming
    var message: String?

    // Formular für eine neue Verordnung
    var formPatientId = "" {
        didSet { if oldValue != formPatientId { formTargetId = "" } }
    }
    var formTargetId = ""
    var formTitle = ""
    var formDetails = ""
    var formFrequency = ""
    var formStartDate = Date()
    var formError: String?
    private(set) var isSaving = false

    private let container: AppContainer

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    var canSave: Bool { !formPatientId.isEmpty && !formTargetId.isEmpty && !formTitle.isBlank && !isSaving }

    func filtered(_ list: [Prescription], orgId: String?) -> [Prescription] {
        switch direction {
        case .incoming: return list.filter { $0.toOrgId == orgId }
        case .outgoing: return list.filter { $0.fromOrgId == orgId }
        }
    }

    func resetForm() {
        formPatientId = ""
        formTargetId = ""
        formTitle = ""
        formDetails = ""
        formFrequency = ""
        formStartDate = Date()
        formError = nil
    }

    /// Neue Verordnung an den Pflegedienst, den der Patient freigegeben hat
    /// - Returns: true bei Erfolg
    func create(patient: Patient?, orgName: String, myName: String) async -> Bool {
        guard let orgId = container.currentOrgId else { return false }
        guard let patient, let patientId = patient.id,
              let target = (patient.linkedOrgs ?? []).first(where: { $0.orgId == formTargetId }) else {
            formError = tr("Bitte Patient und Pflegedienst auswählen.")
            return false
        }
        isSaving = true
        formError = nil
        defer { isSaving = false }

        let prescription = Prescription(
            fromOrgId: orgId,
            fromOrgName: orgName,
            toOrgId: target.orgId,
            toOrgName: target.orgName,
            patientId: patientId,
            patientName: patient.name,
            title: formTitle.trimmed,
            details: formDetails.trimmed,
            frequency: formFrequency.trimmed,
            startDate: formStartDate.atNoon.timestamp,
            createdBy: container.auth.currentUserId ?? "",
            createdByName: myName,
            createdAt: Timestamp()
        )
        do {
            try await container.prescriptions.create(prescription)
            resetForm()
            direction = .outgoing
            return true
        } catch {
            formError = tr("Senden fehlgeschlagen: {0}", error.localizedDescription)
            return false
        }
    }

    /// Pflegedienst übernimmt die Verordnung als Aufträge
    /// - Parameter weekdays: leer = nur ein Auftrag, sonst 1 = Mo bis 7 = So
    func accept(_ prescription: Prescription, start: Date, weekdays: Set<Int>, weeks: Int) {
        let dates = weekdays.isEmpty
            ? [start]
            : Array(recurringDates(start: start, weekdays: weekdays, weeks: weeks).prefix(100))
        guard !dates.isEmpty else {
            message = tr("Im gewählten Zeitraum liegt kein passender Wochentag.")
            return
        }

        var description = prescription.title
        if !prescription.frequency.isBlank { description += " (\(prescription.frequency))" }
        if !prescription.details.isBlank { description += "\n\(prescription.details)" }

        let orders: [Order] = dates.map { date in
            var order = Order(
                state: .offen,
                notes: [tr("Verordnung von {0}", prescription.fromOrgName)],
                description: description,
                patientId: prescription.patientId,
                patientName: prescription.patientName,
                createdBy: container.auth.currentUserId ?? "",
                employeeId: "",
                dueDate: date.timestamp,
                createdAt: Timestamp()
            )
            // ID schon hier vergeben, damit die Verordnung auf den ersten Auftrag zeigen kann
            order.documentId = newId()
            return order
        }

        Task {
            do {
                let orgId = try container.requireOrgId()
                try await container.orders.createMany(orders, orgId: orgId)
                try await container.prescriptions.updateStatus(prescription, status: .angenommen, orderId: orders[0].id)
                message = tr("{0} Auftrag/Aufträge angelegt.", orders.count)
            } catch {
                message = tr("Übernehmen fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }

    func decline(_ prescription: Prescription) { changeStatus(prescription, .abgelehnt) }

    func complete(_ prescription: Prescription) { changeStatus(prescription, .erledigt) }

    func withdraw(_ prescription: Prescription) {
        Task {
            do {
                try await container.prescriptions.withdraw(prescription)
            } catch {
                message = tr("Zurückziehen fehlgeschlagen: {0}", error.localizedDescription)
            }
        }
    }

    private func changeStatus(_ prescription: Prescription, _ status: PrescriptionStatus) {
        Task {
            do {
                try await container.prescriptions.updateStatus(prescription, status: status, orderId: nil)
            } catch {
                message = tr("Status konnte nicht geändert werden: {0}", error.localizedDescription)
            }
        }
    }
}
