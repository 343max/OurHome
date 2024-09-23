#if !os(watchOS)

    import UIKit

    open class SharedAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
        weak var appState: AppState?

        public func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            appState?.deviceToken = tokenParts.joined()
        }
    }

#endif
