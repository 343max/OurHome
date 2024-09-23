import Foundation

class DummyHome: Home {
    let host = URL(string: "https://google.com/")!

    func getState() async throws -> HomeState {
        HomeState(success: true,
                  doorlock: Doorlock(
                      state: doorState,
                      batteryCritical: false,
                      batteryCharging: false,
                      batteryChargeState: 96,
                      success: true
                  ),
                  doorbellAction: doorbellAction)
    }

    func action(_ action: HomeAction) async throws -> HomeResponse {
        switch action {
        case .armBuzzer:
            try await armBuzzer()
        case .armUnlatch:
            try await armUnlatch()
        case .arrived:
            try await arrived()
        case .pressBuzzer:
            try await pressBuzzer()
        case .unlatchDoor:
            try await unlatchDoor()
        case .unlockDoor:
            try await unlockDoor()
        case .lockDoor:
            try await lockDoor()
        }
    }

    private var doorState = DoorlockState.Locked
    private let success = HomeResponse(success: true)
    private var doorbellAction: DoorbellAction?

    private func lockDoor() async throws -> HomeResponse {
        doorState = .Locking
        try await Task.sleep(seconds: 2)
        doorState = .Locked
        return success
    }

    private func unlockDoor() async throws -> HomeResponse {
        doorState = .Unlocking
        try await Task.sleep(seconds: 2)
        doorState = .Unlocked
        return success
    }

    private func armBuzzer() async throws -> HomeResponse {
        try await Task.sleep(seconds: 0.5)
        doorbellAction = DoorbellAction(
            timeout: Date().addingTimeInterval(15).timeIntervalSince1970,
            type: .buzzer
        )
        return success
    }

    private func armUnlatch() async throws -> HomeResponse {
        try await Task.sleep(seconds: 0.5)
        doorbellAction = DoorbellAction(
            timeout: Date().addingTimeInterval(15).timeIntervalSince1970,
            type: .unlatch
        )
        return success
    }

    private func arrived() async throws -> HomeResponse {
        try await Task.sleep(seconds: 0.5)
        doorbellAction = DoorbellAction(
            timeout: Date().addingTimeInterval(3 * 60).timeIntervalSince1970,
            type: .unlatch
        )
        return success
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
