import Foundation

enum URLAction: Equatable {
  case login(username: String, key: String)
  case logout
  case lockDoor
  case pressBuzzer
  case unlockDoor
  case unlatchDoor
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
  case "lockDoor":
    return .lockDoor
  case "pressBuzzer":
    return .pressBuzzer
  case "unlockDoor":
    return .unlockDoor
  case "unlatchDoor":
    return .unlatchDoor

  default:
    return nil
  }
}
