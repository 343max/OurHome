import Foundation

public func getAuthHeader(user: String, secret: String, action: String, timestamp: TimeInterval) -> String {
  let timestampString = "\(UInt(timestamp))"
  let token = [user, secret, action, timestampString].joined(separator: ":").sha256()
  return [user, token, timestampString].joined(separator: ":")
}
