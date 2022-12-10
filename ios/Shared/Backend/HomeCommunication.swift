import Authentication
import Foundation

enum Action: String {
  case lock
  case unlock
  case unlatch
  case buzzer
  case state
  case user
  case doorbell
  case armBuzzer = "arm/buzzer"
  case armUnlatch = "arm/unlatch"
}

enum Method: String {
  case get = "GET"
  case post = "POST"
}

struct AppSecrets {
  let username: String
  let secret: String
}

struct RemoteHome: Home {
  let username: String
  let secret: String

  static let localNetworkHost = URL(string: "http://nuc.fritz.box:4278/")!
  static let externalHost = URL(string: "https://buzzer.343max.de/")!
  
  func url(action: Action, external: Bool = false) -> URL {
    return (external ? RemoteHome.externalHost : RemoteHome.localNetworkHost).appendingPathComponent(action.rawValue)
  }

  func send<T>(_ type: T.Type, _ method: Method, action: Action, external: Bool) async throws -> T where T: Decodable {
    var request = URLRequest(url: url(action: action, external: external))
    request.httpMethod = method.rawValue
    request.addValue(
      getAuthHeader(user: username, secret: secret, action: action.rawValue, timestamp: Date().timeIntervalSince1970),
      forHTTPHeaderField: "Authorization"
    )
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(type, from: data)
  }

  func getState() async throws -> HomeState {
    return try await send(HomeState.self, .get, action: .state, external: true)
  }

  func pressBuzzer() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .buzzer, external: true)
  }

  func unlatchDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .unlatch, external: false)
  }

  func lockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .lock, external: false)
  }

  func unlockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .unlock, external: false)
  }
  
  func armBuzzer() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .armBuzzer, external: true)
  }
  
  func armUnlatch() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .armUnlatch, external: true)
  }
}
