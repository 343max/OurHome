import SwiftUI

@main
struct Our_Home_Watch_AppApp: App {
  @StateObject
  var appState = AppState()
    
  var body: some Scene {
    WindowGroup {
      ControllerView()
    }
    .environmentObject(appState)
  }
}
