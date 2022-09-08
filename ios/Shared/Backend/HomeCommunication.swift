import Authentication
import Foundation

enum Action: String {
  case lock
  case unlock
  case unlatch
  case buzzer
  case state
  case user
  case arrived
  case doorbell
}

enum Method: String {
  case get = "GET"
  case post = "POST"
}

struct AppSecrets {
  let username: String
  let secret: String
}

func sharedHome() -> Home {
  return Home(username: appSecrets.username, secret: appSecrets.secret)
}

struct Home {
  let username: String
  let secret: String

  static let localNetworkHost = URL(string: "http://nuc.fritz.box:4278/")!
  static let externalHost = URL(string: "https://buzzer.343max.de/")!
  
//  let localNetworkHost = "http://localhost:4278/"

  func url(action: Action, external: Bool = false) -> URL {
    return (external ? Home.externalHost : Home.localNetworkHost).appendingPathComponent(action.rawValue)
  }

  func send<T>(_ type: T.Type, _ method: Method, action: Action, external: Bool = false) async throws -> T where T: Decodable {
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
    return try await send(HomeResponse.self, .post, action: .unlatch)
  }

  func lockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .lock)
  }

  func unlockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .unlock)
  }
  
  func arrived() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .arrived)
  }
}
