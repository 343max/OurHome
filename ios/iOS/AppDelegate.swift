import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  weak var pushNotificationSync: PushNotificationSync?
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    self.pushNotificationSync?.deviceToken = tokenParts.joined()
  }
}
