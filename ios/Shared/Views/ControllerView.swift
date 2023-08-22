import SwiftUI

struct ControllerView: View {
  @EnvironmentObject var appState: AppState
    
  var body: some View {
    List {
      Section("Haustür") {
        ActionButton(action: .pressBuzzer)
      }
      
      Section {
        ActionButton(action: .unlatchDoor)
      } header: {
        DoorHeader(doorlock: appState.homeState?.doorlock)
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
        switch(DoorbellAction.getActiveType(appState.homeState?.doorbellAction)) {
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
