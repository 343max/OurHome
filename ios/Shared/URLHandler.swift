import Foundation

enum URLAction: Equatable {
  case login(username: String, key: String)
}

func getAction(url: URL) -> URLAction? {
  let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
  
  guard let components = components else {
    return nil
  }
  
  switch components.host {
  case "login":
    let username = components.queryItems?.first(where: {$0.name == "user"})?.value
    let key = components.queryItems?.first(where: {$0.name == "key"})?.value
    
    guard let username = username, let key = key else {
      return nil
    }
    
    return .login(username: username, key: key)
  default:
    return nil
  }
}
