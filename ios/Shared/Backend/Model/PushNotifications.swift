import Foundation
import SwiftUI

enum PushNotificationType: String, Encodable {
    case doorbellRing
    case whenOtherUserArrives
}

struct PushNotification: Encodable {
    let types: [PushNotificationType]
}

class PushNotificationSync {
    @AppStorage(AppStorageKeys.doorbellRingPushNotification.rawValue)
    var doorbellRingPushNotification = false {
        didSet {
            updatePushNotificationRegistration()
        }
    }

    @AppStorage(AppStorageKeys.whenOtherUserArrivesPushNotification.rawValue)
    var whenOtherUserArrivesPushNotification = false {
        didSet {
            updatePushNotificationRegistration()
        }
    }

    var home: RemoteHome? {
        willSet {
            if newValue == nil {
                deletePushNotificationRegistration()
            }
        }
        didSet {
            updatePushNotificationRegistration()
        }
    }

    var deviceToken: String? {
        willSet {
            if let deviceToken, deviceToken != newValue {
                deletePushNotificationRegistration()
            }
        }
        didSet {
            updatePushNotificationRegistration()
        }
    }

    func updatePushNotificationRegistration() {
        Task {
            guard let deviceToken, let home else {
                return
            }

            let types: [PushNotificationType] = Array([
                .doorbellRing: doorbellRingPushNotification,
                .whenOtherUserArrives: whenOtherUserArrivesPushNotification,
            ].filter(\.value).keys)

            do {
                let _ = try await home.registerPush(deviceToken: deviceToken, notifications: types)
            }
        }
    }

    func deletePushNotificationRegistration() {
        Task {
            guard let deviceToken, let home else {
                return
            }

            do {
                let _ = try await home.unregisterPush(deviceToken: deviceToken)
            }
        }
    }
}
