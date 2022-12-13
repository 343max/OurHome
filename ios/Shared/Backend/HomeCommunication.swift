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
  case arrived
}

enum Method: String {
  case get = "GET"
  case post = "POST"
}

struct RemoteHome: Home {
  let username: String
  let secret: String

  let localNetworkHost: URL
  let externalHost: URL
  
  init(username: String, secret: String) {
    self.username = username
    self.secret = secret
    if let host = ProcessInfo.processInfo.environment["HOST"], host.hasPrefix("http") {
      let url = URL(string: host)!
      self.localNetworkHost = url
      self.externalHost = url
    } else {
      self.localNetworkHost = URL(string: "http://nuc.fritz.box:4278/")!
      self.externalHost = URL(string: "https://buzzer.343max.de/")!
    }
  }
  
  func url(action: Action, external: Bool = false) -> URL {
    return (external ? externalHost : localNetworkHost).appendingPathComponent(action.rawValue)
  }

  func send<T>(_ type: T.Type, _ method: Method, action: Action, external: Bool) async throws -> T where T: Decodable {
    let url = url(action: action, external: external).appending(queryItems: [URLQueryItem(name: "refresh", value: String(Date().timeIntervalSince1970))])
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    request.httpMethod = method.rawValue
    let authorization = getAuthHeader(user: username, secret: secret, action: action.rawValue, timestamp: Date().timeIntervalSince1970)
    request.addValue(authorization, forHTTPHeaderField: "Authorization")
    
    print("curl -X \(method.rawValue) --header \"Authorization: \(authorization)\" \(url.absoluteString)")
    
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

  func arrived() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .post, action: .arrived, external: true)
  }
}
