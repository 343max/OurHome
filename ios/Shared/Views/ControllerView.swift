import SwiftUI
#if !os(watchOS)
import Inject
#endif

struct ControllerView: View {
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  
  @ObservedObject var externalReachability = NetworkReachability(hostName: Home.externalHost.host!)
  @ObservedObject var internalReachabiliy = NetworkReachability(hostName: Home.localNetworkHost.host!)
  
  #if !os(watchOS)
  @ObserveInjection var inject
  #endif

  func loadState() {
    Task {
      do {
        let state = try await sharedHome().getState()
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
        BuzzerButton().disabled(!externalReachability.reachable)
      }
      Section {
        UnlatchDoorButton(refresh: loadState).disabled(!internalReachabiliy.reachable)
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      Section {
        UnlockDoorButton(refresh: loadState).disabled(!internalReachabiliy.reachable)
        LockDoorButton(refresh: loadState).disabled(!internalReachabiliy.reachable)
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
    ControllerView()
  }
}
