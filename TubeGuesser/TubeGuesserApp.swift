import SwiftUI
import UserNotifications
import UIKit
import StoreKit

@main
struct TubeGuesserApp: App {
    private let notificationManager = NotificationManager.shared

    init() {
        notificationManager.requestPermission()
        notificationManager.scheduleDailyNotification()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()

        // Remove any existing notifications
        center.removeAllPendingNotificationRequests()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "TubeGuessr"
        content.body = "🚇 Ready for today's challenge? A new London Underground station is waiting!"
        content.sound = .default
        content.badge = 1

        // Schedule for 9 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request
        let request = UNNotificationRequest(
            identifier: "daily-station-reminder",
            content: content,
            trigger: trigger
        )

        // Add the request
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled for 9:00 AM")
            }
        }
    }

    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-station-reminder"])
    }

    func updateNotificationSettings(enabled: Bool) {
        if enabled {
            scheduleDailyNotification()
        } else {
            cancelDailyNotification()
        }
    }

    func clearBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Error clearing badge: \(error.localizedDescription)")
                }
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}
