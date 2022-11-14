//

import SwiftUI

@main
struct Our_Home_Watch_AppApp: App {
  let home = RemoteHome(username: appSecrets.username, secret: appSecrets.secret)
  var body: some Scene {
    WindowGroup {
      ControllerView(home: home)
    }
  }
}
