import SwiftUI

struct SpinningButton<Content: View>: View {
  @Binding var spinning: Bool
  @Binding var exclamationMark: Bool
  let action: () -> Void
  var label: () -> Content

  var body: some View {
    Button(action: action) {
      HStack {
        label()
        Spacer()
        if (exclamationMark) {
          Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
        }
        if (spinning) {
          Spinner(spinning: .constant(true))
        }
      }
    }
  }
}

struct SpinningButton_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SpinningButton(spinning: .constant(true), exclamationMark: .constant(false)) {
        print("click!")
      } label: {
        Label("Haustür öffnen", systemImage: "figure.walk")
      }
      SpinningButton(spinning: .constant(false), exclamationMark: .constant(true)) {
        print("click!")
      } label: {
        Label("Charge Battery", systemImage: "battery.100.bolt")
      }.disabled(true)
    }
  }
}
