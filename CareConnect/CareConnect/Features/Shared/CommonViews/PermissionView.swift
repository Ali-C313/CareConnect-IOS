//
//  PermissionView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import Foundation

struct PermissionView: View {
    
    /// Berechtigungsmanager
    @StateObject private var permissions = PermissionManager.shared
    
    /// UI-Inhalt
    var body: some View {
        List {
            Section("Standort") {
                Button("Standortberechtigung anfragen") {
                    permissions.requestLocationPermission()
                }
                Text(permissions.locationAuthorized ? "✅ Erlaubt" : "❌ Nicht erlaubt")
            }
            
            Section("Benachrichtigungen") {
                Button("Benachrichtigungen erlauben") {
                    permissions.requestNotificationPermission()
                }
                Text(permissions.notificationsAuthorized ? "✅ Erlaubt" : "❌ Nicht erlaubt")
            }
            
            Section("Kamera & Fotos") {
                Button("Kamera erlauben") {
                    permissions.requestCameraPermission()
                }
                Button("Fotos erlauben") {
                    permissions.requestPhotoPermission()
                }
            }
        }
        .navigationTitle("Berechtigungen")
    }
}


#Preview {
    PermissionView()
}