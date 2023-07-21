import SwiftUI

struct SpinningButton<Content: View>: View {
  let spinning: Bool
  let exclamationMark: Bool
  let action: () -> Void
  var label: () -> Content

  var body: some View {
    Button(action: action) {
      HStack {
        label()
        Spacer()
        if exclamationMark {
          Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
        }
        if spinning {
          ProgressView().frame(maxWidth: 20)
        }
      }
    }
  }
}

struct SpinningButton_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SpinningButton(spinning: true, exclamationMark: false) {
        print("click!")
      } label: {
        Label("Haustür öffnen", systemImage: "figure.walk")
      }
      SpinningButton(spinning: false, exclamationMark: true) {
        print("click!")
      } label: {
        Label("Charge Battery", systemImage: "battery.100.bolt")
      }.disabled(true)
    }
  }
}
