import Foundation

enum Access: String, Codable {
  case full
  case local
  case none
}

struct User: Codable {
  let name: String
  let secret: String
  let access: Access
}

func findUser(name: String) -> User? {
  let usersPath = [FileManager().currentDirectoryPath, "users.json"].joined(separator: "/")
  do {
    let data = try Data(contentsOf: URL(fileURLWithPath: usersPath))
    let users = try JSONDecoder().decode(Array<User>.self, from: data)
    return users.first { $0.name == name }
  } catch {
    print("Couldn't read \(usersPath): \(error.localizedDescription)")
    exit(1)
  }
}
