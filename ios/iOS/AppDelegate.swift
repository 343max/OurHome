import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    weak var pushNotificationSync: PushNotificationSync?

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        pushNotificationSync?.deviceToken = tokenParts.joined()
    }
}
