import SwiftUI

enum LockState {
  case locked
  case unlocked
  case unreachable
}

struct DoorHeader: View {
  let doorlock: Doorlock?
  
  var batteryState: BatteryState? {
    guard let doorlock else {
      return nil
    }
    
    return BatteryState(
      level: doorlock.batteryChargeState,
      charging: doorlock.batteryCharging,
      critical: doorlock.batteryCritical
    )
  }
  
  var lockState: LockState? {
    guard let doorlock else {
      return nil
    }

    switch doorlock.state {
    case .Locked:
      return .locked
    case .Unlocked:
      return .unlocked
    default:
      return nil
    }
  }

  var lockImage: String {
    guard let lockState = lockState else {
      return "hourglass"
    }
    switch lockState {
    case .unlocked:
      return "lock.open.fill"
    case .locked:
      return "lock.fill"
    case .unreachable:
      return "lock.slash"
    }
  }

  var body: some View {
    HStack {
      Label("Wohnungstür", systemImage: lockImage)
      if let batteryState {
        Spacer()
        BatteryIcon(state: batteryState)
      }
    }
  }
}

struct DoorHeader_Previews: PreviewProvider {
  static var previews: some View {
    List {
      Section {
        Text("unlocked")
      } header: {
        DoorHeader(
          doorlock: Doorlock(
            state: .Unlocked,
            batteryCritical: false,
            batteryCharging: true,
            batteryChargeState: 95,
            success: true
          )
        )
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          doorlock: Doorlock(
            state: .Locked,
            batteryCritical: false,
            batteryCharging: true,
            batteryChargeState: 95,
            success: true
          )
        )
      }
      Section {
        Text("unreachable")
      } header: {
        DoorHeader(
          doorlock: nil
        )
      }
      Section {
        Text("waiting")
      } header: {
        DoorHeader(
          doorlock: nil
        )
      }
    }
  }
}
