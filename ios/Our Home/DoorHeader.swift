import SwiftUI

struct DoorHeader: View {
  @Binding var locked: Bool
  @Binding var batteryLevel: Int
  @Binding var batteryCharging: Bool
  @Binding var batteryCritical: Bool

  var body: some View {
    HStack {
      Label("Wohnungstür", systemImage: locked ? "lock" : "lock.open")
      Spacer()
      BatteryIcon(level: $batteryLevel, charging: $batteryCharging, criticial: $batteryCritical)
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
          batteryLevel: .constant(95),
          batteryCharging: .constant(true),
          batteryCritical: .constant(false))
      }
      Section {
        Text("locked")
      } header: {
        DoorHeader(
          locked: .constant(true),
          batteryLevel: .constant(95),
          batteryCharging: .constant(true),
          batteryCritical: .constant(false))
      }
    }
  }
}
