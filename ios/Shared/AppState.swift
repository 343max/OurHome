import Foundation

@MainActor
class AppState: ObservableObject {
  @Published
  private(set) var home: Home {
    didSet {
      notificationProvider.home = home
      #if !os(watchOS)
      locationChecker.home = home
      #endif
      pushNotificationSync.home = home as? RemoteHome
      
      if let home = home as? RemoteHome {
        internalPinger = Pinger(url: home.localNetworkHost, initialReachability: false, update: { reachable in
          Task {
            self.internalReachable = reachable
          }
        })
        externalPinger = Pinger(url: home.externalHost, initialReachability: false, update: { reachable in
          Task {
            self.externalReachable = reachable
          }
        })
      } else {
        self.internalPinger = nil
        self.externalPinger = nil
        self.internalReachable = true
        self.externalReachable = true
      }
    }
  }
  
  @Published
  private(set) var homeState: Result<HomeState, Error>? = nil
  
  @Published
  var user: User? = nil
  
  @Published
  var userState = UserState.verifying
  
  @Published
  var internalReachable = false
  
  @Published
  var externalReachable = true
  
  @Published
  var homeActionInProgress: HomeAction? = nil
  
  @Published
  var lastFailedHomeAction: HomeAction? = nil
  
  let notificationProvider: NotificationProvider
  let pushNotificationSync = PushNotificationSync()
  
  var internalPinger: Pinger? = nil
  var externalPinger: Pinger? = nil

  #if !os(watchOS)
  let locationChecker: LocationChecker
  #endif

  init() {
    let home = DummyHome()
    notificationProvider = NotificationProvider(home: home)
    #if !os(watchOS)
    locationChecker = LocationChecker(home: home, notificationProvider: self.notificationProvider)
    #endif
    self.home = home
    loadUser()
  }
}

extension AppState {
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
  
  func refreshHomeState() async {
    do {
      homeState = .success(try await home.getState())
    } catch {
      homeState = .failure(error)
    }
  }
  
  func homeStateNeedsRefresh() {
    Task {
      await refreshHomeState()
    }
  }
  
  func home(action: HomeAction) async throws {
    homeActionInProgress = action
    lastFailedHomeAction = nil
    
    do {
      _ = try await home.action(action)
    } catch {
      homeActionInProgress = nil
      lastFailedHomeAction = action
    }
    
    homeActionInProgress = nil
    lastFailedHomeAction = nil
  }
}
