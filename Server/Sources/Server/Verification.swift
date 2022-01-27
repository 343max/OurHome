import Foundation
import Verification
import Swifter

func verifyAction(user: String, action: Action, secret: String, bodyData: Data) -> Bool {
  let payload: TokenPayload
  do {
    payload = try JSONDecoder().decode(TokenPayload.self, from: bodyData)
  } catch {
    return false
  }
  
  return verifyToken(payload.token, user: user, secret: secret, action: action.rawValue, date: payload.date)
}
