import SwiftUI

enum Destination {
  case settings
}

@main
struct OurHomeApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
  
  let notificationProvider: NotificationProvider
  let locationChecker: LocationChecker
  
  private var deviceToken: String? = nil
  
  @State private var home: Home = DummyHome() {
    didSet {
      notificationProvider.home = home
      locationChecker.home = home
    }
  }
  
  @State private var destination: [Destination] = []
  @State private var user: User? = nil
  @State private var userState = UserState.verifying
  
  init() {
    let home = DummyHome()
    notificationProvider = NotificationProvider(home: home)
    locationChecker = LocationChecker(home: home, notificationProvider: self.notificationProvider)
    self.home = home
  }
  
  var body: some Scene {
    WindowGroup {
        NavigationStack(path: $destination) {
          ControllerView(home: $home)
            .toolbar {
              NavigationLink(value: Destination.settings) {
                SettingsButtonLabel(userState: userState)
              }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationDestination(for: Destination.self) { destination in
              switch destination {
              case .settings:
                SettingsView(userState: userState)
              }
            }
        }
        .onAppear() {
          loadUser()
          
          if ProcessInfo.processInfo.environment["FAKE_PUSH"] == "1" {
            notificationProvider.showBuzzerNotification(delayed: true)
          }
        }
        .onOpenURL(perform: { url in
          handle(url: url)
        })
    }
  }
}

extension OurHomeApp {
  func loadUser() {
    user = User.load()
    guard let user else {
      userState = .loggedOut
      home = DummyHome()
      return
    }
    
    userState = .verifying
    let home = RemoteHome(username: user.username, secret: user.key)
    self.home = home
    Task {
      do {
        let _ = try await home.getState()
        userState = .loggedIn(username: user.username)
      } catch {
        print("error: \(error)")
        userState = .loginFailed(username: user.username)
      }
    }
  }
}

extension OurHomeApp {
  func handle(url: URL) {
    switch (getAction(url: url)) {
    case .login(let username, let key):
      User.store(user: User(username: username, key: key))
      loadUser()
      destination = destination.filter({ $0 != .settings }) + [.settings]
      break
    case .logout:
      try? User.remove()
      loadUser()
    case nil:
      break
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  @Published var deviceToken: String? = nil
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    self.deviceToken = tokenParts.joined()
  }
}
