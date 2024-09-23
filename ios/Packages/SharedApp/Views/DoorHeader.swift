import SwiftUI

enum LockState {
    case locked
    case unlocked
    case unreachable
    case unknown
}

enum LockResult {
    case result(lock: Doorlock)
    case unreachable
    case unknown
}

struct DoorHeader: View {
    let doorlock: LockResult

    var batteryState: BatteryState? {
        guard case let .result(doorlock) = doorlock else {
            return nil
        }

        return BatteryState(
            level: doorlock.batteryChargeState,
            charging: doorlock.batteryCharging,
            critical: doorlock.batteryCritical
        )
    }

    var lockState: LockState {
        switch doorlock {
        case let .result(lock):
            switch lock.state {
            case .Locked:
                .locked
            case .Unlocked:
                .unlocked
            default:
                .unknown
            }
        case .unreachable:
            .unreachable
        case .unknown:
            .unknown
        }
    }

    var lockImage: String {
        switch lockState {
        case .unlocked:
            "lock.open.fill"
        case .locked:
            "lock.fill"
        case .unreachable:
            "lock.slash"
        case .unknown:
            "hourglass"
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
                    doorlock: .result(lock: Doorlock(
                        state: .Unlocked,
                        batteryCritical: false,
                        batteryCharging: true,
                        batteryChargeState: 95,
                        success: true
                    ))
                )
            }
            Section {
                Text("locked")
            } header: {
                DoorHeader(
                    doorlock: .result(lock: Doorlock(
                        state: .Locked,
                        batteryCritical: false,
                        batteryCharging: true,
                        batteryChargeState: 95,
                        success: true
                    )
                    ))
            }
            Section {
                Text("unreachable")
            } header: {
                DoorHeader(
                    doorlock: .unreachable
                )
            }
            Section {
                Text("waiting")
            } header: {
                DoorHeader(
                    doorlock: .unknown
                )
            }
        }
    }
}
