import Swifter
import Dispatch
import Foundation
import Verification

let server = HttpServer()
server["/:user/:action"] = { req in
  let userName = req.params[":user"] ?? ""
  let action = Action(rawValue: req.params[":action"] ?? "")

  guard let action = action else {
    return .notAcceptable
  }
  
  guard let user = findUser(name: userName) else {
    return .unauthorized
  }
  
  let body = Data(req.body)
  guard let verifiedToken = verifiedAction(user: userName, action: action, secret: user.secret, bodyData: body) else {
    return .unauthorized
  }

  if (abs(Int(Date().timeIntervalSince1970) - Int(verifiedToken.date)) > 600) {
    return .unauthorized
  }

  return .ok(.json(["hello": "world", "action": action.rawValue]))
}

let _ = findUser(name: "non existent user")
print("read users.json")

let semaphore = DispatchSemaphore(value: 0)
do {
  try server.start(9080, forceIPv4: true)
  print("Server has started ( port = \(try server.port()) ). Try to connect now...")
  semaphore.wait()
} catch {
  print("Server start error: \(error)")
  semaphore.signal()
}
