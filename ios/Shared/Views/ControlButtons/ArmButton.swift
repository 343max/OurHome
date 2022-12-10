import SwiftUI

private struct Config {
  let label: String
  let systemImage: String
}

struct ArmDoorbellButton: View {
  let action: DoorbellActionType
  let armedAction: DoorbellAction?
  let home: Home
  let refresh: (() -> Void)?
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

struct ArmDoorebellButton_Previews: PreviewProvider {
  static let doorbellAction = DoorbellAction(
    timeout: Date().addingTimeInterval(2 * 60 + 42).timeIntervalSince1970,
    type: .unlatch)
  
  static var previews: some View {
    List {
      Section {
        ArmDoorbellButton(action: .buzzer, armedAction: doorbellAction, home: DummyHome(), refresh: nil)
        ArmDoorbellButton(action: .unlatch, armedAction: doorbellAction, home: DummyHome(), refresh: nil)
      } header: {
        Label("Klingeln zum Öffnen…", systemImage: "bell")
      }
    }.frame(maxHeight: 300).previewLayout(.sizeThatFits)
  }
}
