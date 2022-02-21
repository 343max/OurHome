import SwiftUI

struct LoggingInView: View {
  var body: some View {
    VStack {
      Spinner(spinning: .constant(true))
      Text("Melde dich an…")
    }
  }
}

struct LoggingInView_Previews: PreviewProvider {
  static var previews: some View {
    LoggingInView()
  }
}
