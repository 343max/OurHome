import SwiftUI

struct BatteryState: Identifiable {
    var id: UUID = .init()

    var level: Int
    var charging: Bool
    var critical: Bool
}

struct BatteryIcon: View {
    let state: BatteryState

    #if os(watchOS)
        let showPercentage = false
    #else
        let showPercentage = true
    #endif

    var batteryImage: String {
        if state.level < 20 {
            "battery.0"
        } else if state.level < 45 {
            "battery.25"
        } else if state.level < 70 {
            "battery.50"
        } else if state.level < 95 {
            "battery.75"
        } else {
            "battery.100"
        }
    }

    var body: some View {
        HStack {
            if showPercentage {
                Text("\(state.level)%")
            }
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
            BatteryIcon(state: BatteryState(level: 95, charging: false, critical: false)).padding()
            BatteryIcon(state: BatteryState(level: 85, charging: false, critical: false)).padding()
            BatteryIcon(state: BatteryState(level: 55, charging: false, critical: false)).padding()
            BatteryIcon(state: BatteryState(level: 44, charging: false, critical: false)).padding()
            BatteryIcon(state: BatteryState(level: 28, charging: false, critical: false)).padding()
            BatteryIcon(state: BatteryState(level: 8, charging: false, critical: true)).padding()
            BatteryIcon(state: BatteryState(level: 8, charging: true, critical: true)).padding()
            BatteryIcon(state: BatteryState(level: 96, charging: true, critical: false)).padding()
        }
    }
}
