//
//  CareConnectApp.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

@main
struct CareConnectApp: App {
    /// App-Status
    @StateObject private var appState = AppStateViewModel()

    /// Firebase konfigurieren
    init() {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        Messaging.messaging().delegate = NotificationDelegate.shared
        Messaging.messaging().token { token, error in
            if let token = token {
                print("📲 FCM Token: \(token)")
                if let userId = Auth.auth().currentUser?.uid {
                    Firestore.firestore().collection("users").document(userId).setData(["fcmToken": token], merge: true)
                }
            } else if let error = error {
                print("❌ Error fetching FCM token: \(error.localizedDescription)")
            }
        }
    }

    /// Start-View
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("🔄 Updated FCM Token: \(fcmToken)")
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).setData(["fcmToken": fcmToken], merge: true)
        }
    }
}
