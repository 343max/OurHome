import SwiftUI

struct UnlockDoorButton: View {
  @EnvironmentObject var appState: AppState
  
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await appState.home(action: .unlockDoor)
          try await Task.sleep(seconds: 0.2)
          appState.homeStateNeedsRefresh()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür aufschließen", systemImage: "lock.open")
    }.disabled(spinning || !appState.internalReachable)
  }
}
