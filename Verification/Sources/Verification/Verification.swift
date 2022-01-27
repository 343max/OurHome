import Foundation

public func generateSecret() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map { c in
    return String(c)
  }

  return (0..<32).map { _ in
    let rand = Int.random(in: 0..<letters.count)
    return letters[rand]
  }.joined()
}

public func generateToken(user: String, secret: String, action: String, date: UInt64) -> String {
  let payload = "\(user)\(secret)/\(action)/\(date)"
  return payload.sha256()
}

public func verifyToken(_ token: String, user: String, secret: String, action: String, date: UInt64) -> Bool {
  return token == generateToken(user: user, secret: secret, action: action, date: date)
}

public struct TokenPayload: Codable, Equatable {
  public let token: String
  public let date: UInt64
}

public func generateTokenPayload(user: String, secret: String, action: String, date: UInt64 = UInt64(Date().timeIntervalSince1970)) -> TokenPayload {
  return TokenPayload(
    token: generateToken(user: user, secret: secret, action: action, date: date),
    date: date
  )
}
