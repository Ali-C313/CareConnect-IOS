//
//  AppStateViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import FirebaseAuth
import Combine

/// Steuert globale App-Zustände:
/// - Login / Logout
/// - Sprache
/// - Benutzerstatus
@MainActor
final class AppStateViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    
    // Aktuell eingeloggter Benutzername
    @Published var currentUserName: String = "Unbekannt"
    
    // Aktuell ausgewählter Sprach-Code
    @Published var appLocale: Locale = .current
    
    // Mitarbeiterstatus
    @AppStorage("staffStatus") var staffStatusRaw: String = StaffStatus.available.rawValue
    
    var staffStatus: StaffStatus {
        get { StaffStatus(rawValue: staffStatusRaw) ?? .available }
        set { staffStatusRaw = newValue.rawValue }
    }
    
    // Firebase Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Fehler beim Abmelden: \(error.localizedDescription)")
        }
    }
}
