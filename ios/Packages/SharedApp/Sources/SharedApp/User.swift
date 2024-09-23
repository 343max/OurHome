struct User {
    let username: String
    let key: String
}

enum UserState {
    case loggedOut
    case verifying
    case loggedIn(username: String)
    case loginFailed(username: String)
    case loginExpired(username: String)
}
