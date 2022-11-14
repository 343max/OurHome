import SwiftUI

struct LockDoorButton: View {
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
          _ = try await home.lockDoor()
          try await Task.sleep(seconds: 0.2)
          refresh?()
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
    LockDoorButton(home: DummyHome(), refresh: nil)
  }
}
