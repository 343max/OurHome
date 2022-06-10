import SwiftUI

@main
struct OurHomeApp: App {
  let notificationProvider: NotificationProvider
  let locationChecker: LocationChecker
  
  init() {
    notificationProvider = NotificationProvider()
    locationChecker = LocationChecker(notificationProvider: self.notificationProvider)
  }
  
  var body: some Scene {
    WindowGroup {
//      LoginHandlerView {
        NavigationView {
          ControllerView()
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
