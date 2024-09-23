import SwiftUI

struct SettingsView: View {
    let userState: UserState

    @EnvironmentObject var appState: AppState

    @State var doorbellRingPushNotification = false
    @State var whenOtherUserArrivesPushNotification = false

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
        }
        .navigationTitle("Einstellungen")
        .onAppear {
            doorbellRingPushNotification = appState.doorbellRingPushNotification
            whenOtherUserArrivesPushNotification = appState.whenOtherUserArrivesPushNotification
        }
        .onChange(of: doorbellRingPushNotification) { newValue in
            appState.doorbellRingPushNotification = newValue
        }
        .onChange(of: whenOtherUserArrivesPushNotification) { newValue in
            appState.whenOtherUserArrivesPushNotification = newValue
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userState: .loggedOut)
    }
}
