import Foundation

enum Action: String {
  case lock = "lock"
  case unlock = "unlock"
  case unlatch = "unlatch"
  case buzzer = "buzzer"
  case state = "state"
  case user = "user"
}

enum Method: String {
  case get = "GET"
  case post = "POST"
}

struct Home {
  let username: String
  let secret: String

  let localNetworkHost = "http://plex-server.fritz.box:4278/"

  func url(action: Action) -> URL {
    return URL(string: "\(localNetworkHost)\(action.rawValue)")!
  }

  func send<T>(_ type: T.Type, _ method: Method, action: Action) async throws -> T where T : Decodable {
    var request = URLRequest(url: url(action: action))
    request.httpMethod = method.rawValue
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(type, from: data)
  }

  func getState() async throws -> HomeState {
    return try await send(HomeState.self, .get, action: .state)
  }
}
