import SwiftUI

struct ControllerView: View {
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil

  var body: some View {
    List() {
      Section("Haustür") {
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Haustür öffnen", systemImage: "figure.walk")
        }.disabled(true)
      }
      Section() {
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Wohnungstür öffnen", systemImage: "lock").foregroundColor(.red)
        }
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      Section() {
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Wohnungstür aufschließen", systemImage: "lock.open")
        }
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Wohnungstür abschließen", systemImage: "lock")
        }
      }
    }
      .navigationTitle("Our Home")
      .task {
      do {
        let state = try await Home(username: "max", secret: "03d768a9-30c7-44c4-8cbf-852ab24dea21").getState()
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
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView()
  }
}
