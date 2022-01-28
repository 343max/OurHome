import SwiftUI

struct SpinnerWrapper<Content: View>: View {
  @Binding var spinning: Bool
  var content: () -> Content

  var body: some View {
    HStack {
      content()
      Spacer()
      if (spinning) {
        Spinner(spinning: .constant(true))
      }
    }
  }
}

struct SpinnerWrapper_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SpinnerWrapper(spinning: .constant(true)) {
        Label("Haustür öffnen", systemImage: "figure.walk")
      }
      SpinnerWrapper(spinning: .constant(false)) {
        Label("Haustür öffnen", systemImage: "figure.walk")
      }

    }
  }
}
