import SwiftUI

struct LoggingInView: View {
  var body: some View {
    VStack {
      ProgressView()
      Text("Melde dich an…").padding()
    }
  }
}

struct LoggingInView_Previews: PreviewProvider {
  static var previews: some View {
    LoggingInView()
  }
}
