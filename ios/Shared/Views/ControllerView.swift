import SwiftUI

struct ControllerView: View {
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil

  func loadState() {
    Task {
      do {
        let state = try await sharedHome().getState()
        frontDoorLockState = {
          switch state.doorlock.state {
          case .Locked:
            return .locked
          case .Unlocked:
            return .unlocked
          default:
            return nil
          }
        }()
        frontDoorBatteryState = BatteryState(
          level: state.doorlock.batteryChargeState,
          charging: state.doorlock.batteryCharging,
          critical: state.doorlock.batteryCritical
        )
      } catch {
        frontDoorLockState = .unreachable
        frontDoorBatteryState = nil
      }
    }
  }

  var body: some View {
    List {
      Section("Haustür") {
        BuzzerButton()
      }
      Section {
        UnlatchDoorButton(refresh: loadState)
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      Section {
        UnlockDoorButton(refresh: loadState)
        LockDoorButton(refresh: loadState)
      }
    }
    .navigationTitle("Our Home")
    .onAppear(perform: loadState)
    .refreshable {
      loadState()
    }
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView()
  }
}
