import SwiftUI

struct BuzzerButton: View {
  @EnvironmentObject var appState: AppState

  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await appState.home(action: .pressBuzzer)
          try await Task.sleep(seconds: 0.2)
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Haustüröffner drücken", systemImage: "figure.walk")
    }.disabled(spinning)
  }
}
