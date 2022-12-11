import Foundation

class DummyHome: Home {
  let localNetworkHost = URL(string: "https://google.com/")!
  let externalHost = URL(string: "https://google.com/")!
  
  var doorbellAction: DoorbellAction?
  
  func lockDoor() async throws -> HomeResponse {
    doorState = .Locking
    try await Task.sleep(seconds: 2)
    doorState = .Locked
    return success
  }
  
  func unlockDoor() async throws -> HomeResponse {
    doorState = .Unlocking
    try await Task.sleep(seconds: 2)
    doorState = .Unlocked
    return success
  }
  
  func armBuzzer() async throws -> HomeResponse {
    try await Task.sleep(seconds: 0.5)
    doorbellAction = DoorbellAction(
      timeout: Date().addingTimeInterval(3 * 60).timeIntervalSince1970,
      type: .buzzer
    )
    return success
  }
  
  func armUnlatch() async throws -> HomeResponse {
    try await Task.sleep(seconds: 0.5)
    doorbellAction = DoorbellAction(
      timeout: Date().addingTimeInterval(3 * 60).timeIntervalSince1970,
      type: .unlatch
    )
    return success
  }
  
  private let success = HomeResponse(success: true)
  
  var doorState = DoorlockState.Locked
  
  func getState() async throws -> HomeState {
    return HomeState(success: true,
                     doorlock: Doorlock(mode: 0,
                                        state: doorState,
                                        stateName: "name",
                                        batteryCritical: false,
                                        batteryCharging: false,
                                        batteryChargeState: 96,
                                        success: true),
                     doorbellAction: doorbellAction)
  }
  
  func pressBuzzer() async throws -> HomeResponse {
    try await Task.sleep(seconds: 1)
    return success
  }
  
  func unlatchDoor() async throws -> HomeResponse {
    doorState = .Unlatching
    try await Task.sleep(seconds: 2)
    doorState = .Unlatched
    return success
  }
}
