import Foundation
import UserNotifications
#if os(watchOS)
    import WatchKit
#else
    import UIKit
#endif

enum NotificationId: String {
    case arrived
}

enum ActionId: String {
    case buzzer
    case unlatchDoor
}

class NotificationProvider: NSObject {
    var home: Home
    let categoryIdentifier = "buzzer"

    init(home: Home) {
        self.home = home
        super.init()

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(
            options: [.sound, .alert, .badge])
        { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    NotificationProvider.registerForRemoteNotifications()
                }
            }
        }

        let buzzerAction = UNNotificationAction(identifier: ActionId.buzzer.rawValue,
                                                title: "Türöffner drücken",
                                                options: [.authenticationRequired])

        let openDoorAction = UNNotificationAction(identifier: ActionId.unlatchDoor.rawValue,
                                                  title: "Wohnungstür öffnen",
                                                  options: [.authenticationRequired, .destructive])

        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [buzzerAction, openDoorAction], intentIdentifiers: [])

        center.setNotificationCategories([category])

        center.removeDeliveredNotifications(withIdentifiers: [NotificationId.arrived.rawValue])
    }

    func showBuzzerNotification(delayed: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "Our Home"
        content.subtitle = "Fast zu Hause…"
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier

        let trigger = delayed ? UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) : nil

        let center = UNUserNotificationCenter.current()
        center.add(UNNotificationRequest(identifier: NotificationId.arrived.rawValue,
                                         content: content,
                                         trigger: trigger))

        #if os(watchOS)
            WKApplication.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 5 * 60),
                                                             userInfo: nil)
            { _ in
                center.removeAllDeliveredNotifications()
            }
        #else
            UIApplication.shared.beginBackgroundTask()

            Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: false) { _ in
                center.removeDeliveredNotifications(withIdentifiers: [NotificationId.arrived.rawValue])
            }
        #endif
    }
}

extension NotificationProvider {
    static func registerForRemoteNotifications() {
        #if os(watchOS)
            WKApplication.shared().registerForRemoteNotifications()
        #else
            UIApplication.shared.registerForRemoteNotifications()
        #endif
    }
}

extension NotificationProvider: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.badge, .sound, .banner, .list])
    }

    // would love to use the async handler here, but that crashes because it isn't running on the main thread in iOS 15.5 :(
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task { @MainActor in
            switch response.actionIdentifier {
            case ActionId.buzzer.rawValue:
                let _ = try? await home.action(.pressBuzzer)
            case ActionId.unlatchDoor.rawValue:
                let _ = try? await home.action(.unlatchDoor)
            default:
                break
            }
            completionHandler()
        }
    }
}
