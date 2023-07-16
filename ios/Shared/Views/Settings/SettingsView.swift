import Defaults
import SwiftUI

struct SettingsView: View {
  let userState: UserState
  let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
  @Default(.doorbellRingPushNotification) var doorbellRingPushNotification
  @Default(.whenOtherUserArrivesPushNotification) var whenOtherUserArrivesPushNotification
  
  var body: some View {
    List {
      Section {
        UserView(state: userState)
      } header: {
        Text("Benutzer")
      }
      
      Section("Push Notifications") {
        Toggle("Wenn es klingelt", isOn: $doorbellRingPushNotification)
        Toggle("Wenn jemand ankommt", isOn: $whenOtherUserArrivesPushNotification)
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
