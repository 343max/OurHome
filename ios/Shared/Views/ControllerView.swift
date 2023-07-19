import SwiftUI

struct ControllerView: View {
  @Binding var home: Home
  
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  @State private var doorbellAction: DoorbellAction? = nil
  
  @ObservedObject var nearbyReachability: Reachability
  @ObservedObject var remoteReachabiliy: Reachability
  
  init(home: Binding<Home>, frontDoorLockState: LockState? = nil, frontDoorBatteryState: BatteryState? = nil, doorbellAction: DoorbellAction? = nil) {
    self.nearbyReachability = Reachability(distance: .Nearby, home: home.wrappedValue)
    self.remoteReachabiliy = Reachability(distance: .Remote, home: home.wrappedValue)

    self._home = home
    self.frontDoorLockState = frontDoorLockState
    self.frontDoorBatteryState = frontDoorBatteryState
    self.doorbellAction = doorbellAction
  }
  
  func loadState() {
    Task {
      do {
        let state = try await home.getState()
        
        if let doorlock = state.doorlock {
          frontDoorLockState = {
            switch doorlock.state {
            case .Locked:
              return .locked
            case .Unlocked:
              return .unlocked
            default:
              return nil
            }
          }()
          frontDoorBatteryState = BatteryState(
            level: doorlock.batteryChargeState,
            charging: doorlock.batteryCharging,
            critical: doorlock.batteryCritical
          )
        } else {
          frontDoorLockState = .unreachable
          frontDoorBatteryState = nil
        }
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
      self.loadState()
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
