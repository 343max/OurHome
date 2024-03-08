import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    weak var appState: AppState?

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        appState?.deviceToken = tokenParts.joined()
    }
}
