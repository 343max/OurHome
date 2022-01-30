import SwiftUI

struct UnlatchDoorButton: View {
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await sharedHome().pressBuzzer()
          try await Task.sleep(seconds: 0.2)
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
    UnlatchDoorButton()
  }
}
