import SwiftUI

enum LockState {
  case locked
  case unlocked
  case unreachable
}

struct DoorHeader: View {
  @Binding var lockState: LockState?
  @Binding var batteryState: BatteryState?

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
      if let $batteryState = Binding($batteryState) {
        Spacer()
        BatteryIcon(state: $batteryState)
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
          lockState: .constant(.unlocked),
          batteryState: .constant(BatteryState(level: 95, charging: true, critical: false))
        )
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          lockState: .constant(.locked),
          batteryState: .constant(BatteryState(level: 95, charging: true, critical: false))
        )
      }
      Section {
        Text("unreachable")
      } header: {
        DoorHeader(
          lockState: .constant(.unreachable),
          batteryState: .constant(nil)
        )
      }
      Section {
        Text("waiting")
      } header: {
        DoorHeader(
          lockState: .constant(nil),
          batteryState: .constant(nil)
        )
      }
    }
  }
}
