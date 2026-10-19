//
//  NotificationManager.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import UserNotifications

/// Lokale Benachrichtigungen, solange die App läuft
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Benachrichtigungen erlaubt:", granted)
        }
    }

    func show(id: String, title: String, text: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = .default
        // trigger nil = sofort anzeigen
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: nil))
    }
}
