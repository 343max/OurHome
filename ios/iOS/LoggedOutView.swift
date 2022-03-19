import SwiftUI

struct LoggedOutView: View {
  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      Text("Du bist nicht eingeloggt.")
        .font(.system(.headline))
      Text("Lass dir von Max einen Login-Link zuschicken und klicke ihn an.")
        .font(.system(.body))
        .multilineTextAlignment(.center)
    }.padding()
  }
}

struct LoggedOutView_Previews: PreviewProvider {
  static var previews: some View {
    LoggedOutView()
  }
}
