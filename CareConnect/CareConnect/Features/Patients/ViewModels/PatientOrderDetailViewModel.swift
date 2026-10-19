//
//  PatientOrderDetailViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Live-Standort des Mitarbeiters und Route zur eigenen Adresse
@MainActor
@Observable
final class PatientOrderDetailViewModel {
    private(set) var employeeCoordinate: CLLocationCoordinate2D?
    private(set) var homeCoordinate: CLLocationCoordinate2D?
    private(set) var route: RouteInfo?

    private let container: AppContainer
    private var locationListener: ListenerHandle?
    private var trackedEmployeeId: String?
    private var lastAddress: String?
    private var routeStart: CLLocationCoordinate2D?

    init(container: AppContainer? = nil) {
        let container = container ?? .shared
        self.container = container
    }

    /// Ziel = eigene Adresse aus dem Patientenprofil
    func loadHomeCoordinate(address: String) {
        guard address != lastAddress else { return }
        lastAddress = address
        Task {
            homeCoordinate = await container.geo.coordinate(for: address)
            await updateRoute(force: true)
        }
    }

    /// nil beendet die Live-Ansicht
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

    private func updateRoute(force: Bool) async {
        guard let start = employeeCoordinate, let end = homeCoordinate else {
            route = nil
            return
        }
        guard force || route == nil || GeoService.hasMoved(from: routeStart, to: start) else { return }
        routeStart = start
        route = await container.geo.route(from: start, to: end)
    }
}
