import SwiftUI

private struct Config {
  let label: String
  let systemImage: String
}

struct ArmDoorbellButton: View {
  @EnvironmentObject var appState: AppState

  let action: DoorbellActionType
  let armedAction: DoorbellAction?

  @State var spinning = false
  @State var exclamationMark = false
  
  private var config: Config {
    switch action {
    case .buzzer:
      return Config(label: "…der Haustür", systemImage: "figure.walk")
    case .unlatch:
      return Config(label: "…der Wohnungstür", systemImage: "door.left.hand.closed")
    }
  }
  
  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          switch action {
          case .buzzer:
            _ = try await appState.home(action: .armBuzzer)
          case .unlatch:
            _ = try await appState.home(action: .armUnlatch)
          }
          try await Task.sleep(seconds: 0.2)
          appState.homeStateNeedsRefresh()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      LabeledContent {
        if let armedAction = armedAction, armedAction.type == action {
          CountdownView(timeout: armedAction.timeoutDate)
        }
      } label: {
        Label(config.label, systemImage: config.systemImage)
      }
    }.disabled(spinning)
  }
}
