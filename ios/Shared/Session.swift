import Foundation
//import KeychainAccess

enum LoginState: Equatable {
  case loggedOut
  case loggedIn(username: String, secret: String)
  case loggingIn
}

class Session: ObservableObject {
  @Published public private(set) var loggedInState: LoginState = .loggedOut
//  private let keychain = Keychain(service: "de.343max.ourHome")

  enum Keys: String {
    case username
    case secret
  }

  init() throws {}

//  private func read() throws -> LoginState {
//    let username = try keychain.get(Keys.username.rawValue)
//    let secret = try keychain.get(Keys.secret.rawValue)
//
//    guard let username = username, let secret = secret else {
//      return .loggedOut
//    }
//
//    return .loggedIn(username: username, secret: secret)
//  }

  private func parse(url: URL) -> (String, String)? {
    guard let fragment = url.fragment else {
      return nil
    }

    let parts = fragment.split(separator: ":")

    if parts.count != 2 {
      return nil
    }

    return (String(parts[0]), String(parts[1]))
  }

  func login(url: URL) async throws {
    Task { @MainActor in
      let parts = parse(url: url)

      guard let (username, secret) = parts else {
        return
      }

      print([username, secret].joined(separator: ", "))

      self.loggedInState = .loggingIn
      try await Task.sleep(seconds: 2)
      self.loggedInState = .loggedIn(username: "max", secret: "secret")
    }
  }
}
