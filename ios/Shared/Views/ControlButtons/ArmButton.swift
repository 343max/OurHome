import SwiftUI

private struct Config {
  let label: String
  let systemImage: String
}

struct ArmDoorbellButton: View {
  let action: DoorbellActionType
  let home: Home
  let refresh: (() -> Void)?
  @State var spinning = false
  @State var exclamationMark = false
  
  private var config: Config {
    switch action {
    case .buzzer:
      return Config(label: "…Öffnen der Haustür", systemImage: "figure.walk")
    case .unlatch:
      return Config(label: "…Öffnen der Wohnungstür", systemImage: "door.left.hand.closed")
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
            _ = try await home.armBuzzer()
          case .unlatch:
            _ = try await home.armUnlatch()
          }
          try await Task.sleep(seconds: 0.2)
          refresh?()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label(config.label, systemImage: config.systemImage)
    }.disabled(spinning)
  }
}

struct ArmDoorebellButton_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ArmDoorbellButton(action: .buzzer, home: DummyHome(), refresh: nil)
      ArmDoorbellButton(action: .unlatch, home: DummyHome(), refresh: nil)
    }
  }
}
