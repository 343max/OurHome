import SwiftUI

@main
struct OurHomeApp: App {
  var body: some Scene {
    WindowGroup {
      LoginHandlerView {
        NavigationView {
          ControllerView()
            .toolbar {
              NavigationLink(destination: { SettingsView() }) {
                Label("Einstellungen", systemImage: "slider.horizontal.3")
              }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
      }
    }
  }
}
