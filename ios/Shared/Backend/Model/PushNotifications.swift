import Foundation
import Defaults

enum PushNotificationType: String, Encodable {
  case doorbellRing
  case whenOtherUserArrives
}

struct PushNotification: Encodable {
  let types: [PushNotificationType]
}

func updatePushNotificationRegistration(home: RemoteHome, deviceToken: String) async throws {
  let types: [PushNotificationType] = Array([
    .doorbellRing: Defaults[.doorbellRingPushNotification],
    .whenOtherUserArrives: Defaults[.whenOtherUserArrivesPushNotification]
  ].filter({$0.value}).keys)
  
  let _ = try await home.registerPush(deviceToken: deviceToken, notifications: types)
}
