import KeychainAccess

enum Keys: String {
    case username
    case key
}

extension User {
    static let keychain = Keychain(service: "de.343max.ourhome")

    static func load() -> User? {
        let username = keychain[Keys.username.rawValue]
        let key = keychain[Keys.key.rawValue]

        if let username, let key {
            return User(username: username, key: key)
        } else {
            return nil
        }
    }

    static func store(user: User) {
        keychain[Keys.username.rawValue] = user.username
        keychain[Keys.key.rawValue] = user.key
    }

    static func remove() throws {
        try keychain.removeAll()
    }
}
