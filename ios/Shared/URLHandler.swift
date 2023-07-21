import Foundation

enum URLAction: Equatable {
  case login(username: String, key: String)
  case logout
//  case lock
//  case buzzer
//  case unlock
//  case unlatch
}

func getAction(url: URL) -> URLAction? {
  let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

  guard let components = components else {
    return nil
  }

  switch components.host {
  case "login":
    let username = components.queryItems?.first(where: { $0.name == "user" })?.value
    let key = components.queryItems?.first(where: { $0.name == "key" })?.value

    guard let username = username, let key = key else {
      return nil
    }

    return .login(username: username, key: key)

  case "logout":
    return .logout
//  case "lock":
//    return .lock
//  case "buzzer":
//    return .buzzer
//  case "unlock":
//    return .unlock
//  case "unlatch":
//    return .unlatch

  default:
    return nil
  }
}
