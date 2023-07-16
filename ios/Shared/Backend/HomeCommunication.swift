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
  case pushNotification = "pushnotifications"
}

enum Method: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

enum Route {
  case lan
  case external
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
      localNetworkHost = url
      externalHost = url
    } else {
      localNetworkHost = URL(string: "http://lol.fritz.box:4278/")!
      externalHost = URL(string: "https://buzzer.343max.com/")!
    }
  }

  func url(_ route: Route, _ action: Action, _ path: String? = nil) -> URL {
    let url = (route == .external ? externalHost : localNetworkHost).appendingPathComponent(action.rawValue)
    if let path = path {
      return url.appendingPathComponent(path)
    } else {
      return url
    }
  }

  func send<T>(_ type: T.Type, _ route: Route, _ method: Method, action: Action, _ path: String? = nil, _ body: Encodable? = nil) async throws -> T where T: Decodable {
    let url = url(route, action, path)
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    request.httpMethod = method.rawValue
    let authorization = getAuthHeader(user: username, secret: secret, action: action.rawValue, timestamp: Date().timeIntervalSince1970)
    request.addValue(authorization, forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if let body = body, method == .post || method == .put {
      request.httpBody = try JSONEncoder().encode(body)
    }

    print("curl -X \(method.rawValue) --header \"Authorization: \(authorization)\" \(url.absoluteString)")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(type, from: data)
  }

  func getState() async throws -> HomeState {
    return try await send(HomeState.self, .external, .get, action: .state)
  }

  func pressBuzzer() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .external, .post, action: .buzzer)
  }

  func unlatchDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .lan, .post, action: .unlatch)
  }

  func lockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .lan, .post, action: .lock)
  }

  func unlockDoor() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .lan, .post, action: .unlock)
  }

  func armBuzzer() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .external, .post, action: .armBuzzer)
  }

  func armUnlatch() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .external, .post, action: .armUnlatch)
  }

  func arrived() async throws -> HomeResponse {
    return try await send(HomeResponse.self, .external, .post, action: .arrived)
  }
  
  func registerPush(deviceToken: String, notifications: [PushNotificationType]) async throws -> HomeResponse {
    let body = PushNotification(
      types: notifications
    )
    
    return try await send(HomeResponse.self, .external, .put, action: .pushNotification, deviceToken, body)
  }
  
  func unregisterPush(deviceToken: String) async throws -> HomeResponse {
    return try await send(HomeResponse.self, .external, .delete, action: .pushNotification, deviceToken)
  }
}
