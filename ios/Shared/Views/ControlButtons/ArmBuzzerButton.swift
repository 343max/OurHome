import SwiftUI

struct ArmBuzzerButton: View {
  let home: Home
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await home.armBuzzer()
          try await Task.sleep(seconds: 0.2)
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("…Öffnen der Haustür", systemImage: "figure.walk")
    }.disabled(spinning)
  }
}

struct ArmBuzzerButton_Previews: PreviewProvider {
  static var previews: some View {
    ArmBuzzerButton(home: DummyHome())
  }
}
