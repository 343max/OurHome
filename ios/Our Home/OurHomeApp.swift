import SwiftUI

@main
struct OurHomeApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ControllerView()
//          .toolbar {
//            NavigationLink(destination: { SettingsView() }) {
//              Label("Settings", systemImage: "slider.horizontal.3")
//            }
//          }
      }
    }
  }
}

