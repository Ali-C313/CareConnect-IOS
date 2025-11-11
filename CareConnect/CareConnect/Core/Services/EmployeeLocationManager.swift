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
    @Published var lastUploadStatus: String?

    private let manager = CLLocationManager()
    private var db = Firestore.firestore()
    private var employeeId: String? = nil
    private var orderId: String? = nil
    private var lastUploadDate: Date?

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
    func startTracking(for employeeId: String, orderId: String? = nil) {
        print("📍 Start Location Tracking: \(employeeId) with orderId: \(orderId ?? "none")")
        self.employeeId = employeeId
        self.orderId = orderId
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
        orderId = nil
    }

    // MARK: - Berechtigung
    /// Berechtigung prüfen
    func requestPermissionIfNeeded() {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
        case .denied, .restricted:
            print("⚠️ Standortzugriff wurde verweigert — bitte in den Einstellungen aktivieren.")
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
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
            print("❌ Kein Standortzugriff — bitte Berechtigungen in den Systemeinstellungen aktivieren.")
        default:
            break
        }
    }

    /// Standort aktualisiert
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location

        let now = Date()
        if let lastUpload = lastUploadDate, now.timeIntervalSince(lastUpload) < 10 {
            // Skip upload to respect cooldown
            return
        }
        lastUploadDate = now

        uploadLocation(location)
    }

    /// Standortfehler
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        lastUploadStatus = "Location error: \(error.localizedDescription)"
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

        let documentReference: DocumentReference
        if let orderId = orderId {
            documentReference = db.collection("orders").document(orderId).collection("employeeLocation").document(employeeId)
        } else {
            documentReference = db.collection("employeeLocations").document(employeeId)
        }

        documentReference.setData(data) { error in
            if let error = error {
                print("❌ Fehler beim Upload der Location: \(error.localizedDescription)")
                self.lastUploadStatus = "Upload failed: \(error.localizedDescription)"
            } else {
                print("📡 Standort hochgeladen: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
                self.lastUploadStatus = "Upload successful: (\(location.coordinate.latitude), \(location.coordinate.longitude))"
            }
        }
    }
}
