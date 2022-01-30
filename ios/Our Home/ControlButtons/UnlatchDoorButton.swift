import SwiftUI

struct UnlatchDoorButton: View {
  @State var spinning = false
  @State var exclamationMark = false
  let refresh: (() -> Void)?

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await sharedHome().unlatchDoor()
          try await Task.sleep(seconds: 0.2)
          refresh?()
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Wohnungstür öffnen", systemImage: "lock").foregroundColor(.red)
    }.disabled(spinning)
  }
}

struct UnlatchDoorButton_Previews: PreviewProvider {
  static var previews: some View {
    UnlatchDoorButton(refresh: nil)
  }
}
