import Foundation

struct HomeResponse: Codable {
    let success: Bool
}

struct HomeState: Codable {
    let success: Bool
    let doorlock: Doorlock?
    let doorbellAction: DoorbellAction?
}

enum DoorlockState: Int, Codable {
    case Uncalibrated = 0
    case Locked = 1
    case Unlocking = 2
    case Unlocked = 3
    case Locking = 4
    case Unlatched = 5
    case UnlockedLockNGo = 6
    case Unlatching = 7
    case MotorBlocked = 254
    case Undefined = 255
}

struct Doorlock: Codable {
    let state: DoorlockState
    let batteryCritical: Bool
    let batteryCharging: Bool
    let batteryChargeState: Int
    let success: Bool
}
