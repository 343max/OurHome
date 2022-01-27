import Foundation
import Verification
import Swifter

func verifiedAction(user: String, action: Action, secret: String, bodyData: Data) -> TokenPayload? {
  let payload: TokenPayload
  do {
    payload = try JSONDecoder().decode(TokenPayload.self, from: bodyData)
  } catch {
    return nil
  }
  
  let verified = verifyToken(payload.token, user: user, secret: secret, action: action.rawValue, date: payload.date)
  return verified ? payload : nil
}
