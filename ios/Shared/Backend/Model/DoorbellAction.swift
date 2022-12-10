import Foundation

enum DoorbellActionType: String, Codable {
  case buzzer
  case unlatch
}

struct DoorbellAction: Codable {
  let timeout: Double
  let type: DoorbellActionType
}

extension DoorbellAction {
  var timeoutDate: Date {
    Date(timeIntervalSince1970: timeout)
  }
}
