import Foundation

enum DoorbellActionType: String, Codable {
  case buzzer
  case unlatch
}

struct DoorbellAction: Codable {
  let timeout: Float
  let type: DoorbellActionType
}
