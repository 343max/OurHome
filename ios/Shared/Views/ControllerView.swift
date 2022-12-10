import SwiftUI

struct ControllerView: View {
  let home: Home
  
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  @State private var doorbellAction: DoorbellAction? = nil
  
  @ObservedObject var nearbyReachability = Reachability(distance: .Nearby)
  @ObservedObject var remoteReachabiliy = Reachability(distance: .Remote)
  
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
        doorbellAction = state.doorbellAction
      } catch {
        frontDoorLockState = .unreachable
        frontDoorBatteryState = nil
        doorbellAction = nil
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

      Section {
        ArmDoorbellButton(action: .buzzer, armedAction: doorbellAction, home: home, refresh: loadState)
        ArmDoorbellButton(action: .unlatch, armedAction: doorbellAction, home: home, refresh: loadState)
      } header: {
        Label("Klingeln zum Öffnen…", systemImage: "bell")
      } footer: {
        switch(doorbellAction?.type) {
        case nil:
          EmptyView()
        case .buzzer:
          Text("Klingle jetzt um die Haustür zu öffnen").frame(maxWidth: .infinity)
        case .unlatch:
          Text("Klingle jetzt, um die Wohunungstür zu öffnen").frame(maxWidth: .infinity)
        }
      }
    }
    .navigationTitle("Our Home")
    .onAppear(perform: loadState)
    .refreshable {
      loadState()
    }
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView(home: DummyHome())
  }
}
