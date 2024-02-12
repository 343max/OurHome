import Defaults
import Foundation

enum PushNotificationType: String, Encodable {
    case doorbellRing
    case whenOtherUserArrives
}

struct PushNotification: Encodable {
    let types: [PushNotificationType]
}

class PushNotificationSync {
    var observer: Defaults.Observation?

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

    init() {
        observer = Defaults.observe(keys: .doorbellRingPushNotification, .whenOtherUserArrivesPushNotification, options: [], handler: { [weak self] in
            self?.updatePushNotificationRegistration()
        })
    }

    func updatePushNotificationRegistration() {
        Task {
            guard let deviceToken, let home else {
                return
            }

            let types: [PushNotificationType] = Array([
                .doorbellRing: Defaults[.doorbellRingPushNotification],
                .whenOtherUserArrives: Defaults[.whenOtherUserArrivesPushNotification],
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
