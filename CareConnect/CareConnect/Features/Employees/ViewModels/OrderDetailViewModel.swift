//
//  OrderDetailViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Live-Karte, Route und Aktionen für einen Auftrag (Daten kommen aus dem AppStateViewModel)
@MainActor
@Observable
final class OrderDetailViewModel {
    private(set) var employeeCoordinate: CLLocationCoordinate2D?
    private(set) var patientCoordinate: CLLocationCoordinate2D?
    private(set) var route: RouteInfo?
    private(set) var isProcessing = false
    var errorMessage: String?

    private let container: AppContainer
    private var locationListener: ListenerHandle?
    private var trackedEmployeeId: String?
    private var lastAddress: String?
    private var routeStart: CLLocationCoordinate2D?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Patientenadresse → Koordinate, nur wenn sich die Adresse geändert hat
    func loadPatientCoordinate(address: String) {
        guard address != lastAddress else { return }
        lastAddress = address
        Task {
            patientCoordinate = await container.geo.coordinate(for: address)
            await updateRoute(force: true)
        }
    }

    /// Live-Standort des Mitarbeiters, nur solange der Auftrag aktuell ist
    func observeLocation(of employeeId: String?) {
        guard employeeId != trackedEmployeeId else { return }
        stopListening()
        trackedEmployeeId = employeeId
        guard let employeeId, !employeeId.isEmpty, let orgId = container.currentOrgId else { return }
        locationListener = container.locations.listen(orgId: orgId, employeeId: employeeId) { [weak self] coordinate in
            self?.employeeCoordinate = coordinate
            Task { await self?.updateRoute(force: false) }
        }
    }

    func stopListening() {
        locationListener?.remove()
        locationListener = nil
        trackedEmployeeId = nil
        employeeCoordinate = nil
        route = nil
    }

    /// Route erst neu holen, wenn sich der Mitarbeiter ein Stück bewegt hat
    private func updateRoute(force: Bool) async {
        guard let start = employeeCoordinate, let end = patientCoordinate else {
            route = nil
            return
        }
        guard force || route == nil || GeoService.hasMoved(from: routeStart, to: start) else { return }
        routeStart = start
        route = await container.geo.route(from: start, to: end)
    }

    // MARK: - Aktionen

    func accept(_ order: Order) {
        guard let employeeId = container.auth.currentUserId else { return }
        runAction(tr("Fehler beim Annehmen")) { orgId in
            try await self.container.orders.accept(orgId: orgId, id: order.id, employeeId: employeeId)
        }
    }

    /// Abschließen mit Leistungsnachweis
    func complete(_ order: Order, note: String, signature: String, signedBy: String, myName: String) {
        let report = CompletionReport(
            note: note.trimmed,
            signature: signature,
            signedBy: signedBy.trimmed,
            completedBy: container.auth.currentUserId ?? "",
            completedByName: myName
        )
        runAction(tr("Fehler beim Abschließen")) { orgId in
            try await self.container.orders.complete(orgId: orgId, id: order.id, report: report)
        }
    }

    func delete(_ order: Order, onDeleted: @escaping () -> Void) {
        runAction(tr("Fehler beim Löschen")) { orgId in
            try await self.container.orders.delete(orgId: orgId, id: order.id)
            onDeleted()
        }
    }

    private func runAction(_ errorText: String, _ action: @escaping (String) async throws -> Void) {
        guard !isProcessing else { return }
        Task {
            isProcessing = true
            defer { isProcessing = false }
            do {
                try await action(try container.requireOrgId())
            } catch {
                errorMessage = "\(errorText): \(error.localizedDescription)"
            }
        }
    }
}
