import Foundation

enum HomeAction {
    case armBuzzer
    case armUnlatch
    case arrived
    case lockDoor
    case pressBuzzer
    case unlatchDoor
    case unlockDoor
}

protocol Home {
    var localNetworkHost: URL { get }
    var externalHost: URL { get }

    func getState() async throws -> HomeState

    func action(_ action: HomeAction) async throws -> HomeResponse
}

@MainActor
func actionReachable(_ action: HomeAction, appState: AppState) -> Bool {
    switch action {
    case .armBuzzer, .armUnlatch, .pressBuzzer, .arrived:
        appState.externalReachable
    case .lockDoor, .unlockDoor, .unlatchDoor:
        appState.internalReachable
    }
}
