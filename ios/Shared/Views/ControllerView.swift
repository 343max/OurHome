import SwiftUI
#if !os(watchOS)
import Inject
#endif

struct ControllerView: View {
  let home: Home
  
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  
  @ObservedObject var nearbyReachability = Reachability(distance: .Nearby)
  @ObservedObject var remoteReachabiliy = Reachability(distance: .Remote)
  
  #if !os(watchOS)
  @ObserveInjection var inject
  #endif

  func loadState() {
    Task {
      do {
        let state = try await home.getState()
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
        BuzzerButton(home: home)
          .disabled(!remoteReachabiliy.reachable)
      }
      Section {
        UnlatchDoorButton(home: home,
                          refresh: loadState)
        .disabled(!nearbyReachability.reachable)
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      Section {
        UnlockDoorButton(home: home, refresh: loadState)
          .disabled(!nearbyReachability.reachable)
        LockDoorButton(home: home, refresh: loadState)
          .disabled(!nearbyReachability.reachable)
      }
    }
    .navigationTitle("Our Home")
    .onAppear(perform: loadState)
    .refreshable {
      loadState()
    }
    #if !os(watchOS)
    .enableInjection()
    #endif
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView(home: DummyHome())
  }
}
