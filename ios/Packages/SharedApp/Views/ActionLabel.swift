import SwiftUI

struct ActionLabel: View {
    let action: HomeAction
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        switch action {
        case .armBuzzer:
            Label("…der Haustür", systemImage: "figure.walk")
        case .armUnlatch:
            Label("…der Wohnungstür", systemImage: "door.left.hand.closed")
        case .arrived:
            Text("Arrived")
        case .lockDoor:
            Label("Wohnungstür abschließen", systemImage: "lock")
        case .pressBuzzer:
            Label("Haustüröffner drücken", systemImage: "figure.walk")
        case .unlatchDoor:
            Label("Wohnungstür öffnen", systemImage: "door.left.hand.closed").foregroundColor(.red.opacity(isEnabled ? 1 : 0.5))
        case .unlockDoor:
            Label("Wohnungstür aufschließen", systemImage: "lock.open")
        }
    }
}
