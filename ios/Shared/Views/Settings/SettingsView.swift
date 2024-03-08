import SwiftUI

struct SettingsView: View {
    let userState: UserState

    @AppStorage(AppStorageKeys.doorbellRingPushNotification.rawValue)
    var doorbellRingPushNotification = false

    @AppStorage(AppStorageKeys.whenOtherUserArrivesPushNotification.rawValue)
    var whenOtherUserArrivesPushNotification = false

    var body: some View {
        List {
            Section {
                UserView(state: userState)
            } header: {
                Text("Benutzer")
            }

            if case .loggedIn = userState {
                Section("Push Notifications") {
                    Toggle("Wenn es klingelt", isOn: $doorbellRingPushNotification)
                    Toggle("Wenn jemand ankommt", isOn: $whenOtherUserArrivesPushNotification)
                }
            }

            #if !os(watchOS)
                Section {
                    Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                        Label("Systemeinstellungen öffnen", systemImage: "gear")
                    }
                }
            #endif

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
