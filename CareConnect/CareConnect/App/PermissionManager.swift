//
//  PermissionManager.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import CoreLocation
import UserNotifications
import AVFoundation
import Photos
import UIKit
import Combine

@MainActor
final class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = PermissionManager()
    
    private var locationManager: CLLocationManager?
    
    @Published var locationAuthorized = false
    @Published var notificationsAuthorized = false
    @Published var cameraAuthorized = false
    @Published var photosAuthorized = false
    
    // MARK: - Standort
    func requestLocationPermission() {
        Task { @MainActor in
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationAuthorized = true
            default:
                self.locationAuthorized = false
            }
        }
    }
    
    // MARK: - Push Notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                self.notificationsAuthorized = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Kamera
    func requestCameraPermission() {
        Task.detached {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                await MainActor.run { self.cameraAuthorized = true }
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run { self.cameraAuthorized = granted }
            default:
                await MainActor.run { self.cameraAuthorized = false }
            }
        }
    }
    
    // MARK: - Fotos
    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            Task { @MainActor in
                self.photosAuthorized = (status == .authorized || status == .limited)
            }
        }
    }
    
    // MARK: - Alle Berechtigungen
    func requestAllPermissions() {
        requestLocationPermission()
        requestNotificationPermission()
        requestCameraPermission()
        requestPhotoPermission()
    }
}
