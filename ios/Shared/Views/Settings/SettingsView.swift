import SwiftUI

struct SettingsView: View {
  let userState: UserState
  
  var body: some View {
    List {
      Section {
        UserView(state: userState)
      } header: {
        Text("Benutzer")
      }

      Section {
        Text("Version \(appVersion())").foregroundColor(.secondary)
      }
    }.navigationTitle("Einstellungen")
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(userState: .loggedOut)
  }
}
