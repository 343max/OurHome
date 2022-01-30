import SwiftUI

struct UnlockDoorButton: View {
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await sharedHome().unlockDoor()
          try await Task.sleep(seconds: 0.2)
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
    UnlockDoorButton()
  }
}
