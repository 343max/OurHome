import Swifter
import Dispatch
import Foundation
import Verification

let server = HttpServer()
server["/:user/:action"] = { req in
  let body = Data(req.body)
  let user = req.params[":user"] ?? ""
  let action = Action(rawValue: req.params[":action"] ?? "")

  guard let action = action else {
    return .notAcceptable
  }
  
  return .ok(.json(["hello": "world", "action": action.rawValue]))
}

let semaphore = DispatchSemaphore(value: 0)
do {
  try server.start(9080, forceIPv4: true)
  print("Server has started ( port = \(try server.port()) ). Try to connect now...")
  semaphore.wait()
} catch {
  print("Server start error: \(error)")
  semaphore.signal()
}
