import SwiftUI

struct ActionButton: View {
  let action: HomeAction
  @EnvironmentObject var appState: AppState
  
  var spinning: Bool {
    appState.homeActionInProgress == action
  }
  
  var exclamationMark: Bool {
    appState.lastFailedHomeAction == action
  }
  
  var body: some View {
    SpinningButton(spinning: spinning, exclamationMark: exclamationMark) {
      Task {
        do {
          _ = try await appState.home(action: action)
          try await Task.sleep(seconds: 0.2)
          appState.homeStateNeedsRefresh()
        }
      }
    } label: {
      ActionLabel(action: action)
    }.disabled(spinning || !actionReachable(action, appState: appState))
  }
}
