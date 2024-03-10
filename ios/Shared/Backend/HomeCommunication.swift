import Authentication
import Foundation

enum Action: String {
    case lock
    case unlock
    case unlatch
    case buzzer
    case state
    case user
    case doorbell
    case armBuzzer = "arm/buzzer"
    case armUnlatch = "arm/unlatch"
    case arrived
    case pushNotification = "pushnotifications"
}

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct RemoteHome: Home {
    let username: String
    let secret: String

    let host: URL

    init(username: String, secret: String) {
        self.username = username
        self.secret = secret
        if let host = ProcessInfo.processInfo.environment["HOST"], host.hasPrefix("http") {
            self.host = URL(string: host)!
        } else {
            host = URL(string: "https://buzzer.343max.com/")!
        }
    }

    func action(_ action: HomeAction) async throws -> HomeResponse {
        switch action {
        case .armBuzzer:
            try await armBuzzer()
        case .armUnlatch:
            try await armUnlatch()
        case .arrived:
            try await arrived()
        case .pressBuzzer:
            try await pressBuzzer()
        case .unlatchDoor:
            try await unlatchDoor()
        case .unlockDoor:
            try await unlockDoor()
        case .lockDoor:
            try await lockDoor()
        }
    }

    struct PushNotification: Encodable {
        let types: [PushNotificationType]
    }

    func registerPush(deviceToken: String, notifications: [PushNotificationType]) async throws -> HomeResponse {
        let body = PushNotification(
            types: notifications
        )

        return try await send(HomeResponse.self, .put, action: .pushNotification, deviceToken, body)
    }

    func unregisterPush(deviceToken: String) async throws -> HomeResponse {
        try await send(HomeResponse.self, .delete, action: .pushNotification, deviceToken)
    }

    private func url(_ action: Action, _ path: String? = nil) -> URL {
        let url = host.appendingPathComponent(action.rawValue)
        if let path {
            return url.appendingPathComponent("\(path)")
        } else {
            return url
        }
    }

    private func send<T>(_ type: T.Type, _ method: Method, action: Action, _ path: String? = nil, _ body: Encodable? = nil) async throws -> T where T: Decodable {
        let url = url(action, path)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = method.rawValue
        let authorization = getAuthHeader(user: username, secret: secret, action: action.rawValue, timestamp: Date().timeIntervalSince1970)
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body, method == .post || method == .put {
            request.httpBody = try JSONEncoder().encode(body)
        }

        print("curl -X \(method.rawValue) --header \"Authorization: \(authorization)\" \(url.absoluteString)")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(type, from: data)
    }

    func getState() async throws -> HomeState {
        try await send(HomeState.self, .get, action: .state)
    }

    private func pressBuzzer() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .buzzer)
    }

    private func unlatchDoor() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .unlatch)
    }

    private func lockDoor() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .lock)
    }

    private func unlockDoor() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .unlock)
    }

    private func armBuzzer() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .armBuzzer)
    }

    private func armUnlatch() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .armUnlatch)
    }

    private func arrived() async throws -> HomeResponse {
        try await send(HomeResponse.self, .post, action: .arrived)
    }
}
