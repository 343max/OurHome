import SwiftUI

enum Destination {
  case settings
}

@main
struct OurHomeApp: App {
  let notificationProvider: NotificationProvider
  let locationChecker: LocationChecker
  
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
                switch userState {
                case .loggedOut:
                  Label("Einstellungen", systemImage: "teddybear").foregroundColor(.orange)
                case .loginFailed:
                  Label("Einstellungen", systemImage: "person.crop.circle.badge.exclamationmark.fill").foregroundColor(.red)
                case .loginExpired:
                  Label("Einstellungen", systemImage: "calendar.badge.exclamationmark").foregroundColor(.red)
                case .loggedIn, .verifying:
                  Label("Einstellungen", systemImage: "slider.horizontal.3")
                }
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
    home = RemoteHome(username: user.username, secret: user.key)
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
