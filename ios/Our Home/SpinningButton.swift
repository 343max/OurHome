import SwiftUI

struct SpinningButton<Content: View>: View {
  @Binding var spinning: Bool
  let action: () -> Void
  var label: () -> Content

  var body: some View {
    Button(action: action) {
      SpinnerWrapper(spinning: $spinning, content: label)
    }
  }
}

struct SpinningButton_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SpinningButton(spinning: .constant(true)) {
        print("click!")
      } label: {
        Label("Haustür öffnen", systemImage: "figure.walk")
      }
      SpinningButton(spinning: .constant(false), action: { print("click!") }) {
        Label("Charge Battery", systemImage: "battery.100.bolt")
      }.disabled(true)
    }
  }
}
