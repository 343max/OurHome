import SwiftUI

struct ControllerView: View {
  let home: Binding<Home>
  
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  @State private var doorbellAction: DoorbellAction? = nil
  
  @ObservedObject var nearbyReachability: Reachability
  @ObservedObject var remoteReachabiliy: Reachability
  
  init(home: Binding<Home>, frontDoorLockState: LockState? = nil, frontDoorBatteryState: BatteryState? = nil, doorbellAction: DoorbellAction? = nil) {
    self.nearbyReachability = Reachability(distance: .Nearby, home: home.wrappedValue)
    self.remoteReachabiliy = Reachability(distance: .Remote, home: home.wrappedValue)

    self.home = home
    self.frontDoorLockState = frontDoorLockState
    self.frontDoorBatteryState = frontDoorBatteryState
    self.doorbellAction = doorbellAction
    
    self.loadState()
  }
  
  func loadState() {
    Task {
      do {
        let state = try await home.wrappedValue.getState()
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
        BuzzerButton(home: home.wrappedValue)
          .disabled(!remoteReachabiliy.reachable)
      }
      
      Section {
        UnlatchDoorButton(home: home.wrappedValue,
                          refresh: loadState)
        .disabled(!nearbyReachability.reachable)
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      
      Section {
        UnlockDoorButton(home: home.wrappedValue, refresh: loadState)
          .disabled(!nearbyReachability.reachable)
        LockDoorButton(home: home.wrappedValue, refresh: loadState)
          .disabled(!nearbyReachability.reachable)
      }

      Section {
        ArmDoorbellButton(action: .buzzer, armedAction: doorbellAction, home: home.wrappedValue, refresh: loadState)
        ArmDoorbellButton(action: .unlatch, armedAction: doorbellAction, home: home.wrappedValue, refresh: loadState)
      } header: {
        Label("Klingeln zum Öffnen…", systemImage: "bell")
      } footer: {
        switch(DoorbellAction.getActiveType(doorbellAction)) {
        case nil:
          EmptyView()
        case .buzzer:
          Text("Klingle jetzt um die Haustür zu öffnen").frame(maxWidth: .infinity)
        case .unlatch:
          Text("Klingle jetzt, um die Wohunungstür zu öffnen").frame(maxWidth: .infinity)
        }
      }
    }
    .onAppear(perform: {
      loadState()
    })
    .navigationTitle("Our Home")
    .refreshable {
      self.loadState()
    }
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView(home: .constant(DummyHome()))
  }
}
