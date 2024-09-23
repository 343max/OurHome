import SwiftUI

struct ControllerView: View {
    @EnvironmentObject var appState: AppState

    var doorlock: LockResult {
        guard let homeState = appState.homeState else {
            return .unknown
        }

        switch homeState {
        case let .success(success):
            if let doorlock = success.doorlock {
                return .result(lock: doorlock)
            } else {
                return .unreachable
            }
        case .failure:
            return .unreachable
        }
    }

    var homeState: HomeState? {
        guard let homeState = appState.homeState else {
            return nil
        }

        switch homeState {
        case let .success(state):
            return state
        case .failure:
            return nil
        }
    }

    var body: some View {
        List {
            Section("Haustür") {
                ActionButton(action: .pressBuzzer)
            }

            #if !os(watchOS)
                Section {
                    ActionButton(action: .unlatchDoor)
                } header: {
                    DoorHeader(doorlock: doorlock)
                }

                Section {
                    ActionButton(action: .unlockDoor)
                    ActionButton(action: .lockDoor)
                }
            #endif

            Section {
                ActionButton(action: .armUnlatch)
                ActionButton(action: .armBuzzer)
            } header: {
                Label("Klingeln zum Öffnen…", systemImage: "bell")
            } footer: {
                switch DoorbellAction.getActiveType(homeState?.doorbellAction) {
                case nil:
                    EmptyView()
                case .buzzer:
                    Text("Klingle jetzt um die Haustür zu öffnen").frame(maxWidth: .infinity)
                case .unlatch:
                    Text("Klingle jetzt, um die Wohunungstür zu öffnen").frame(maxWidth: .infinity)
                }
            }
            #if os(watchOS)
                Section {
                    NavigationLink(value: Destination.settings) {
                        SettingsButtonLabel(userState: appState.userState)
                    }
                }
            #endif
        }
        #if !os(watchOS)
        .navigationTitle("Our Home")
        #endif
        .refreshable {
            await appState.refreshHomeState()
        }
        .onAppear {
            Task {
                await appState.refreshHomeState()
            }
        }
    }
}
