import SwiftUI

struct UnlatchDoorButton: View {
  @EnvironmentObject var appState: AppState
  
  @State var spinning = false
  @State var exclamationMark = false
  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await appState.home.action(.unlatchDoor)
          try await Task.sleep(seconds: 0.2)
          appState.homeStateNeedsRefresh()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür öffnen", systemImage: "door.left.hand.closed").foregroundColor(.red.opacity(isEnabled ? 1 : 0.5))
    }.disabled(spinning)
  }
}
