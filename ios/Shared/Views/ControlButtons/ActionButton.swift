import SwiftUI

struct ActionButton: View {
  let action: HomeAction
  @EnvironmentObject var appState: AppState
  
  var spinning: Bool {
    appState.homeActionInProgress == action
  }
  
  var exclamationMark: Bool {
    
  }
  
  var body: some View {
    SpinningButton(spinning: spinning, exclamationMark: appState.lastFailedHomeAction == action) {
      Task {
        do {
          _ = try await appState.home(action: action)
          try await Task.sleep(seconds: 0.2)
          appState.homeStateNeedsRefresh()
        }
      }
    } label: {
      Label("Wohnungstür aufschließen", systemImage: "lock.open")
    }.disabled(!appState.internalReachable)
  }
}
