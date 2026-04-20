import Foundation
import UserNotifications
import UIKit

actor PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    private var deviceToken: String?
    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            if granted {
                await registerForRemoteNotifications()
            }
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    @MainActor
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func didRegisterForRemoteNotifications(deviceToken token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        self.deviceToken = nil
    }

    func getDeviceToken() -> String? {
        deviceToken
    }

    func scheduleLocalNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval = 1
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }
}
