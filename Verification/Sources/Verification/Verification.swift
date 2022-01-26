public func generateSecret() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map { c in
    return String(c)
  }

  return (0..<32).map { _ in
    let rand = Int.random(in: 0..<letters.count)
    return letters[rand]
  }.joined()
}

public func generateToken(secret: String, action: String, date: Int64) -> String {
  let payload = "\(secret)/\(action)/\(date)"
  return payload.sha256()
}

public func verifyToken(_ token: String, secret: String, action: String, date: Int64) -> Bool {
  return token == generateToken(secret: secret, action: action, date: date)
}
