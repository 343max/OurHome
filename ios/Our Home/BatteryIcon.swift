import SwiftUI

struct BatteryIcon: View {
  @Binding var level: Int
  @Binding var charging: Bool
  @Binding var criticial: Bool

  var batteryImage: String {
    get {
      if level < 20 {
        return "battery.0"
      } else if level < 45 {
        return "battery.25"
      } else if level < 70 {
        return "battery.50"
      } else if level < 95 {
        return "battery.75"
      } else {
        return "battery.100"
      }
    }
  }

  var body: some View {
    ZStack {
      Image(systemName: batteryImage).foregroundColor(criticial ? .red : (charging ? .gray : nil))
      if charging {
        Image(systemName: "bolt.fill").foregroundColor(.white)
        Image(systemName: "bolt")
      }
    }
  }
}

struct BatteryIcon_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      BatteryIcon(level: .constant(95), charging: .constant(false), criticial: .constant(false)).padding()
      BatteryIcon(level: .constant(85), charging: .constant(false), criticial: .constant(false)).padding()
      BatteryIcon(level: .constant(55), charging: .constant(false), criticial: .constant(false)).padding()
      BatteryIcon(level: .constant(44), charging: .constant(false), criticial: .constant(false)).padding()
      BatteryIcon(level: .constant(28), charging: .constant(false), criticial: .constant(false)).padding()
      BatteryIcon(level: .constant(8), charging: .constant(false), criticial: .constant(true)).padding()
      BatteryIcon(level: .constant(8), charging: .constant(true), criticial: .constant(true)).padding()
      BatteryIcon(level: .constant(96), charging: .constant(true), criticial: .constant(false)).padding()
    }
  }
}
