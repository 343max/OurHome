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
    var host: URL { get }

    func getState() async throws -> HomeState

    func action(_ action: HomeAction) async throws -> HomeResponse
}

@MainActor
func actionReachable(_ action: HomeAction, appState: AppState) -> Bool {
    switch action {
    case .armBuzzer, .armUnlatch, .pressBuzzer, .arrived:
        true
    case .lockDoor, .unlockDoor, .unlatchDoor:
        appState.nearby
    }
}
