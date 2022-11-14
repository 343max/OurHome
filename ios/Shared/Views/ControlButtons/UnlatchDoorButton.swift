import SwiftUI

struct UnlatchDoorButton: View {
  let home: Home
  @State var spinning = false
  @State var exclamationMark = false
  let refresh: (() -> Void)?
  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await home.unlatchDoor()
          try await Task.sleep(seconds: 0.2)
          refresh?()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür öffnen", systemImage: "lock").foregroundColor(.red.opacity(isEnabled ? 1 : 0.5))
    }.disabled(spinning)
  }
}

struct UnlatchDoorButton_Previews: PreviewProvider {
  static var previews: some View {
    UnlatchDoorButton(home: DummyHome(), refresh: nil)
  }
}
