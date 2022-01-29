import SwiftUI

enum OptionalBatteryState {
  case unknown
  case known(state: BatteryState)
}

struct DoorHeader: View {
  @Binding var locked: Bool?
  @Binding var batteryState: BatteryState?
  
  var lockImage: String {
    get {
      guard let locked = locked else {
        return "lock.slash"
      }
      return locked ? "lock" : "lock.open"
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
          locked: .constant(false),
          batteryState: .constant(BatteryState(level: 95, charging: true, critical: false))
        )
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          locked: .constant(true),
          batteryState: .constant(BatteryState(level: 95, charging: true, critical: false))
        )
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          locked: .constant(true),
          batteryState: .constant(nil)
        )
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          locked: .constant(nil),
          batteryState: .constant(nil)
        )
      }

    }
  }
}
