import SwiftUI

struct UserView: View {
  let state: UserState
  let minHeight = CGFloat(100)
  
  var inviteButton: some View {
    Link("Max nach Schlüssel-Link fragen", destination: URL(string: "sms://+491759116208")!)
    .font(.callout)
    .foregroundColor(.primary)
    .colorInvert()
    .buttonStyle(.borderedProminent)
  }
  
  var body: some View {
    switch state {
    case .loggedOut:
      VStack {
        Image(systemName: "teddybear.fill")
        Text("Demo Mode").bold()
        Text("Keine Zugangsdaten").padding(1)
        Text("Die App kann derzeit nicht als Schlüssel genutzt werden.").multilineTextAlignment(.center)
        inviteButton
      }
        .foregroundColor(.orange)
        .frame(maxWidth: .infinity, minHeight: minHeight)
    case .verifying:
      VStack {
        ProgressView().padding()
        Text("Überprüfe Zugangsdaten…")
      }
      .frame(maxWidth: .infinity, minHeight: minHeight)
    case .loggedIn(let username):
      VStack {
        Image(systemName: "person")
        Text(username).bold()
      }
      .frame(maxWidth: .infinity, minHeight: minHeight)
    case .loginFailed(let username):
      VStack {
        Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
        Text(username).bold()
        Text("Zugangsdaten ungültig")
        inviteButton
      }
      .foregroundColor(.red)
      .frame(maxWidth: .infinity, minHeight: minHeight)
    case .loginExpired(let username):
      VStack {
        Image(systemName: "calendar.badge.exclamationmark")
        Text(username).bold()
        Text("Zugangsdaten abgelaufen")
        inviteButton
      }
      .foregroundColor(.red)
      .frame(maxWidth: .infinity, minHeight: minHeight)
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      Section {
        UserView(state: .loggedOut)
      } header: {
        Text("Benutzer")
      }
      Section {
        UserView(state: .verifying)
      } header: {
        Text("Benutzer")
      }
      Section {
        UserView(state: .loggedIn(username: "max"))
      } header: {
        Text("Benutzer")
      }
      Section {
        UserView(state: .loginFailed(username: "dr evil"))
      } header: {
        Text("Benutzer")
      }
      Section {
        UserView(state: .loginExpired(username: "mom"))
      } header: {
        Text("Benutzer")
      }
    }.previewLayout(.sizeThatFits)
  }
}
