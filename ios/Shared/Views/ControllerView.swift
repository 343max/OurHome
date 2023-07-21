import SwiftUI

struct ControllerView: View {
  @EnvironmentObject var appState: AppState
  
  @State private var frontDoorLockState: LockState? = nil
  @State private var frontDoorBatteryState: BatteryState? = nil
  @State private var doorbellAction: DoorbellAction? = nil
  
  init(frontDoorLockState: LockState? = nil, frontDoorBatteryState: BatteryState? = nil, doorbellAction: DoorbellAction? = nil) {
    self.frontDoorLockState = frontDoorLockState
    self.frontDoorBatteryState = frontDoorBatteryState
    self.doorbellAction = doorbellAction
  }
  
  var body: some View {
    List {
      Section("Haustür") {
        BuzzerButton()
          .disabled(!appState.externalReachable)
      }
      
      Section {
        UnlatchDoorButton()
        .disabled(!appState.internalReachable)
      } header: {
        DoorHeader(lockState: $frontDoorLockState, batteryState: $frontDoorBatteryState)
      }
      
      Section {
        UnlockDoorButton()
        LockDoorButton()
      }

      Section {
        ArmDoorbellButton(action: .buzzer, armedAction: doorbellAction)
        ArmDoorbellButton(action: .unlatch, armedAction: doorbellAction)
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
    .navigationTitle("Our Home")
    .refreshable {
      await appState.refreshHomeState()
    }
  }
}

extension ControllerView {
  func apply(homeState: HomeState?) {
    let (lockState, batteryState, doorbellAction) = from(homeState: homeState)
    self.frontDoorLockState = lockState
    self.frontDoorBatteryState = batteryState
    self.doorbellAction = doorbellAction
  }
  
  func from(homeState: HomeState?) -> (LockState?, BatteryState?, DoorbellAction?) {
    guard let homeState else {
      return (.unreachable, nil, nil)
    }
    
    guard let doorlock = homeState.doorlock else {
      return (.unreachable, nil, homeState.doorbellAction)
    }
    
    let frontDoorLockState: LockState? = {
      switch doorlock.state {
      case .Locked:
        return .locked
      case .Unlocked:
        return .unlocked
      default:
        return nil
      }
    }()
    
    let frontDoorBatteryState = BatteryState(
      level: doorlock.batteryChargeState,
      charging: doorlock.batteryCharging,
      critical: doorlock.batteryCritical
    )
    
    return (frontDoorLockState, frontDoorBatteryState, homeState.doorbellAction)
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView()
  }
}
