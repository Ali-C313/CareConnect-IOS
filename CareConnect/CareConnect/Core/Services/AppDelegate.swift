//
//  AppDelegate.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.11.25.
//

import Foundation
import UIKit
import Firebase
import UserNotifications


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Notification setup
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization(application)
        
        // Set Messaging delegate
        Messaging.messaging().delegate = self
        
        return true
    }
    
    private func requestNotificationAuthorization(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("❌ Push notifications not authorized: \(error?.localizedDescription ?? "none")")
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs token registered.")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("❌ No FCM token available.")
            return
        }
        print("✅ FCM Token: \(token)")
    }
}
