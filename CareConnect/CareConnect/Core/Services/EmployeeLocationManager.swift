//
//  EmployeeLocationManager.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// GPS des Mitarbeiters, läuft nur während ein Auftrag aktuell ist
@Observable
final class EmployeeLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = EmployeeLocationManager()

    private(set) var lastLocation: CLLocation?
    private(set) var isTracking = false

    private let manager = CLLocationManager()
    private let locations: LocationRepository
    private var employeeId: String?
    private var orgId: String?
    private var lastUpload: Date?

    /// Mindestabstand zwischen zwei Uploads
    private let uploadInterval: TimeInterval = 10

    init(locations: LocationRepository? = nil) {
        self.locations = locations ?? AppContainer.shared.locations
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.pausesLocationUpdatesAutomatically = true
    }

    func startTracking(for employeeId: String, orgId: String) {
        guard !employeeId.isBlank else { return }
        if isTracking && self.employeeId == employeeId && self.orgId == orgId { return }
        self.employeeId = employeeId
        self.orgId = orgId
        lastUpload = nil
        isTracking = true

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginUpdates()
        default:
            print("Standortzugriff verweigert")
        }
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        // Standort löschen, damit der Patient keinen alten Punkt sieht
        if let employeeId, let orgId {
            Task { try? await locations.clear(orgId: orgId, employeeId: employeeId) }
        }
        employeeId = nil
        orgId = nil
        isTracking = false
    }

    private func beginUpdates() {
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard employeeId != nil else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            beginUpdates()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let employeeId, let orgId else { return }
        lastLocation = location

        if let lastUpload, Date().timeIntervalSince(lastUpload) < uploadInterval { return }
        lastUpload = Date()

        Task {
            try? await self.locations.upload(location.coordinate, orgId: orgId, employeeId: employeeId)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Standortfehler:", error.localizedDescription)
    }
}
