import SwiftUI

struct ControllerView: View {
  @EnvironmentObject var appState: AppState
  
  var doorlock: LockResult {
    guard let homeState = appState.homeState else {
      return .unknown
    }
    
    switch homeState {
    case .success(let success):
      if let doorlock = success.doorlock {
        return .result(lock: doorlock)
      } else {
        return .unreachable
      }
    case .failure(_):
      return .unreachable
    }
  }
  
  var homeState: HomeState? {
    guard let homeState = appState.homeState else {
      return nil
    }
    
    switch homeState {
    case .success(let state):
      return state
    case .failure(_):
      return nil
    }
  }
    
  var body: some View {
    List {
      Section("Haustür") {
        ActionButton(action: .pressBuzzer)
      }
      
      Section {
        ActionButton(action: .unlatchDoor)
      } header: {
        DoorHeader(doorlock: doorlock)
      }
      
      Section {
        ActionButton(action: .unlockDoor)
        ActionButton(action: .lockDoor)
      }

      Section {
        ActionButton(action: .armBuzzer)
        ActionButton(action: .armUnlatch)
      } header: {
        Label("Klingeln zum Öffnen…", systemImage: "bell")
      } footer: {
        switch(DoorbellAction.getActiveType(homeState?.doorbellAction)) {
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
    .onAppear {
      Task {
        await appState.refreshHomeState()
      }
    }
  }
}
