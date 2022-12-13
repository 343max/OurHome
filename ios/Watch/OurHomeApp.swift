import SwiftUI

@main
struct Our_Home_Watch_AppApp: App {
  let home = DummyHome()
  var body: some Scene {
    WindowGroup {
      ControllerView(home: .constant(home))
    }
  }
}
