import SwiftUI

struct LockDoorButton: View {
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await sharedHome().lockDoor()
          try await Task.sleep(seconds: 0.2)
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür abschließen", systemImage: "lock")
    }.disabled(spinning)
  }
}

struct LockDoorButton_Previews: PreviewProvider {
  static var previews: some View {
    LockDoorButton()
  }
}
