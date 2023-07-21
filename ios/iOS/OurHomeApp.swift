import SwiftUI

enum Destination {
  case settings
}

extension EnvironmentValues {
  struct HomeKey: EnvironmentKey {
    static var defaultValue: Home = DummyHome()
  }
  
  var home: Home {
    get { self[HomeKey.self] }
    set { self[HomeKey.self] = newValue }
  }
}

@main
struct OurHomeApp: App {
  @UIApplicationDelegateAdaptor
  private var appDelegate: AppDelegate
  
  @StateObject
  var appState = AppState()
    
  @State private var destination: [Destination] = []
  
  var body: some Scene {
    WindowGroup {
        NavigationStack(path: $destination) {
          ControllerView()
            .toolbar {
              NavigationLink(value: Destination.settings) {
                SettingsButtonLabel(userState: appState.userState)
              }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationDestination(for: Destination.self) { destination in
              switch destination {
              case .settings:
                SettingsView(userState: appState.userState)
              }
            }
        }
        .onAppear() {
          self.appDelegate.pushNotificationSync = appState.pushNotificationSync
          appState.loadUser()
          
          UIApplication.shared.registerForRemoteNotifications()
          
          if ProcessInfo.processInfo.environment["FAKE_PUSH"] == "1" {
            appState.notificationProvider.showBuzzerNotification(delayed: true)
          }
        }
        .onOpenURL(perform: { url in
          handle(url: url)
        })
        .environmentObject(appState)
    }
  }
}

extension OurHomeApp {
  func handle(url: URL) {
    func trigger(action: HomeAction) {
      Task {
        try? await appState.home(action: action)
      }
    }
    
    guard let action = getAction(url: url) else {
      return
    }
    
    switch (action) {
    case .login(let username, let key):
      User.store(user: User(username: username, key: key))
      appState.loadUser()
      destination = destination.filter({ $0 != .settings }) + [.settings]
      break
    case .logout:
      try? User.remove()
      appState.loadUser()
    case .lockDoor:
      trigger(action: .lockDoor)
    case .pressBuzzer:
      trigger(action: .pressBuzzer)
    case .unlockDoor:
      trigger(action: .unlockDoor)
    case .unlatchDoor:
      trigger(action: .unlatchDoor)
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  weak var pushNotificationSync: PushNotificationSync?
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    self.pushNotificationSync?.deviceToken = tokenParts.joined()
  }
}
