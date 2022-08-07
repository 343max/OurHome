import Foundation

import UserNotifications

class NotificationProvider: NSObject {
  let categoryIdentifier = "buzzer"
  
  override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
    
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.sound, .alert, .badge]) { _, _ in }
    
    let buzzerAction = UNNotificationAction(identifier: "buzzer",
                                            title: "Türöffner drücken",
                                            options: [.authenticationRequired, .destructive])
    
    let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [buzzerAction], intentIdentifiers: [])
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
  }
  
  func showBuzzerNotification(delayed: Bool = false) {
    let content = UNMutableNotificationContent()
    content.title = "Our Home"
    content.subtitle = "Fast zu Hause…"
    content.sound = .default
    content.categoryIdentifier = categoryIdentifier
    
    let trigger = delayed ? UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) : nil
    
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString,
                                                                 content: content,
                                                                 trigger: trigger))
  }
}

extension NotificationProvider: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.badge, .sound])
  }
  
  // would love to use the async handler here, but that crashes because it isn't running on the main thread in iOS 15.5 :(
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    Task { @MainActor in
      let _ = try? await sharedHome().pressBuzzer()
      completionHandler()
    }
  }
}
