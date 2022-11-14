import SwiftUI

@main
struct OurHomeApp: App {
  let home: Home
  let notificationProvider: NotificationProvider
  let locationChecker: LocationChecker
  
  init() {
    home = RemoteHome(username: appSecrets.username, secret: appSecrets.secret)
    notificationProvider = NotificationProvider(home: home)
    locationChecker = LocationChecker(home: home, notificationProvider: self.notificationProvider)
  }
  
  var body: some Scene {
    WindowGroup {
//      LoginHandlerView {
        NavigationView {
          ControllerView(home: home)
//            .toolbar {
//              NavigationLink(destination: { SettingsView() }) {
//                Label("Einstellungen", systemImage: "slider.horizontal.3")
//              }
//            }
//        }
        .navigationViewStyle(StackNavigationViewStyle())
        }.onAppear() {
          if ProcessInfo.processInfo.environment["FAKE_PUSH"] == "1" {
            notificationProvider.showBuzzerNotification(delayed: true)
          }
        }
    }
  }
}
