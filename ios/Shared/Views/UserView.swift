import SwiftUI

struct UserView: View {
    let state: UserState
    let minHeight = CGFloat(100)

    var inviteButton: some View {
        Link("Max kontaktieren", destination: URL(string: "sms://+491759116208")!)
            .font(.callout)
            .buttonStyle(.bordered)
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
        case let .loggedIn(username):
            VStack {
                Image(systemName: "person.crop.circle")
                Text(username).bold()
                Text("Der Schlüssel funktioniert")
            }
            .foregroundColor(.cyan)
            .frame(maxWidth: .infinity, minHeight: minHeight)
        case let .loginFailed(username):
            VStack {
                Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                Text(username).bold()
                Text("Zugangsdaten ungültig")
                inviteButton
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, minHeight: minHeight)
        case let .loginExpired(username):
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
