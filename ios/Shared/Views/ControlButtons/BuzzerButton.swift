import SwiftUI

struct BuzzerButton: View {
  let home: Home
  @State var spinning = false
  @State var exclamationMark = false

  var body: some View {
    SpinningButton(spinning: $spinning, exclamationMark: $exclamationMark) {
      Task {
        spinning = true
        do {
          exclamationMark = false
          _ = try await home.pressBuzzer()
          try await Task.sleep(seconds: 0.2)
        } catch {
          exclamationMark = true
        }
        spinning = false
      }
    } label: {
      Label("Haustüröffner drücken", systemImage: "figure.walk")
    }.disabled(spinning)
  }
}

struct BuzzerButton_Previews: PreviewProvider {
  static var previews: some View {
    BuzzerButton(home: DummyHome())
  }
}
