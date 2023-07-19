import Defaults
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
      
      if case .loggedIn(_) = userState {
        Section("Push Notifications") {
          Defaults.Toggle("Wenn es klingelt", key: .doorbellRingPushNotification)
          Defaults.Toggle("Wenn jemand ankommt", key: .whenOtherUserArrivesPushNotification)
        }
      }
      
      Section {
        Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
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
