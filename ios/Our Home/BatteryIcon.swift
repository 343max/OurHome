import SwiftUI

struct BatteryState: Identifiable {
  var id: UUID = .init()
  
  var level: Int
  var charging: Bool
  var critical: Bool
}

struct BatteryIcon: View {
  @Binding var state: BatteryState

  var batteryImage: String {
    get {
      if state.level < 20 {
        return "battery.0"
      } else if state.level < 45 {
        return "battery.25"
      } else if state.level < 70 {
        return "battery.50"
      } else if state.level < 95 {
        return "battery.75"
      } else {
        return "battery.100"
      }
    }
  }

  var body: some View {
    HStack {
      Text("\(state.level)%")
      ZStack {
        Image(systemName: batteryImage).foregroundColor(state.critical ? .red : (state.charging ? .gray : nil))
        if state.charging {
          Image(systemName: "bolt.fill").foregroundColor(.white)
          Image(systemName: "bolt")
        }
      }
    }
  }
}

struct BatteryIcon_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      BatteryIcon(state: .constant(BatteryState(level: 95, charging: false, critical: false))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 85, charging:false, critical:false))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 55, charging:false, critical:false))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 44, charging:false, critical:false))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 28, charging:false, critical:false))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 8, charging:false, critical:true))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 8, charging:true, critical:true))).padding()
      BatteryIcon(state: .constant(BatteryState(level: 96, charging:true, critical:false))).padding()
    }
  }
}
