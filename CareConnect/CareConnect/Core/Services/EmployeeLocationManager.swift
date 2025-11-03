//
//  EmployeeLocationManager.swift
//  CareConnect
//
//  Created by Ali Chehab on 29.10.25.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import Combine

class EmployeeLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = EmployeeLocationManager()

    /// Letzter Standort
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()
    private var db = Firestore.firestore()
    private var employeeId: String? = nil

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
    }

    // MARK: - Aktivieren
    /// Tracking starten
    func startTracking(for employeeId: String) {
        print("📍 Start Location Tracking: \(employeeId)")
        self.employeeId = employeeId
        requestPermissionIfNeeded()
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    /// Tracking stoppen
    func stopTracking() {
        print("🛑 Stop Location Tracking")
        manager.allowsBackgroundLocationUpdates = false
        manager.stopUpdatingLocation()
        employeeId = nil
    }

    // MARK: - Berechtigung
    /// Berechtigung prüfen
    private func requestPermissionIfNeeded() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
        }
    }

    // MARK: - Delegate
    /// Berechtigungsänderung
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Standortzugriff erlaubt")
            if employeeId != nil {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print("❌ Kein Standortzugriff")
        default:
            break
        }
    }

    /// Standort aktualisiert
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        uploadLocation(location)
    }

    /// Standortfehler
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }

    // MARK: - Firestore Upload
    /// Standort hochladen
    private func uploadLocation(_ location: CLLocation) {
        guard let employeeId else { return }
        let data: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude,
            "updatedAt": Timestamp(date: Date())
        ]

        db.collection("employeeLocations").document(employeeId).setData(data) { error in
            if let error = error {
                print("❌ Fehler beim Upload der Location: \(error.localizedDescription)")
            } else {
                print("📡 Standort hochgeladen: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            }
        }
    }
}
