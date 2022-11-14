import SwiftUI

struct UnlockDoorButton: View {
  let home: Home
  let refresh: (() -> Void)?

  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await home.unlockDoor()
          try await Task.sleep(seconds: 0.2)
          refresh?()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür aufschließen", systemImage: "lock.open")
    }.disabled(spinning)
  }
}

struct UnlockDoorButton_Previews: PreviewProvider {
  static var previews: some View {
    UnlockDoorButton(home: DummyHome(), refresh: nil)
  }
}
