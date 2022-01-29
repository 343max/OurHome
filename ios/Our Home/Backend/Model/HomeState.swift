import Foundation

// MARK: - Welcome
struct HomeState: Codable {
  let success: Bool
  let doorlock: Doorlock
}

// MARK: - Doorlock
struct Doorlock: Codable {
  let mode, state: Int
  let stateName: String
  let batteryCritical: Bool
  let batteryCharging: Bool
  let batteryChargeState: Int
  let success: Bool
}
