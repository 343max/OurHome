import SwiftUI

struct SettingsView: View {
  let userState: UserState
  let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
  
  var body: some View {
    List {
      Section {
        UserView(state: userState)
      } header: {
        Text("Benutzer")
      }
      
      Section {
        Link(destination: settingsUrl) {
          Label("Systemeinstellungen öffnen", systemImage: "gear")
        }
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
