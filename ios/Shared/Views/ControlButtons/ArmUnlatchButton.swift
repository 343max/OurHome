import SwiftUI

struct ArmUnlatchButton: View {
  let home: Home
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await home.armUnlatch()
          try await Task.sleep(seconds: 0.2)
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("…Öffnen der Wohnungstür", systemImage: "door.left.hand.closed")
    }.disabled(spinning)
  }
}

struct ArmUnlatchButton_Previews: PreviewProvider {
  static var previews: some View {
    ArmUnlatchButton(home: DummyHome())
  }
}
