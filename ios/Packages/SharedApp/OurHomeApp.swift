import SwiftUI

enum Destination {
    case settings
}

extension EnvironmentValues {
    struct HomeKey: EnvironmentKey {
        static var defaultValue: Home = DummyHome()
    }

    var home: Home {
        get { self[HomeKey.self] }
        set { self[HomeKey.self] = newValue }
    }
}

@main
struct OurHomeApp: App {
    #if !os(watchOS)
        @UIApplicationDelegateAdaptor
        private var appDelegate: AppDelegate
    #endif

    @StateObject
    var appState = AppState()

    @State private var destination: [Destination] = []

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $destination) {
                ControllerView()
                #if !os(watchOS)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            NavigationLink(value: Destination.settings) {
                                SettingsButtonLabel(userState: appState.userState)
                            }
                        }
                    }
                #endif
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .settings:
                            SettingsView(userState: appState.userState)
                        }
                    }
            }
            .onAppear {
                #if !os(watchOS)
                    appDelegate.appState = appState
                #endif
                appState.loadUser()

                NotificationProvider.registerForRemoteNotifications()

                if ProcessInfo.processInfo.environment["FAKE_PUSH"] == "1" {
                    appState.notificationProvider.showBuzzerNotification(delayed: true)
                }
            }
            .onOpenURL(perform: { url in
                handle(url: url)
            })
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { activity in
                guard let url = activity.webpageURL else {
                    return
                }
                handle(url: url)
            })
            .environmentObject(appState)
        }
    }
}

extension OurHomeApp {
    func handle(url: URL) {
        func trigger(action: HomeAction) {
            Task {
                try? await appState.home(action: action)
            }
        }

        guard let action = getAction(url: url) else {
            return
        }

        switch action {
        case let .login(username, key):
            User.store(user: User(username: username, key: key))
            appState.loadUser()
            destination = destination.filter { $0 != .settings } + [.settings]
        case .logout:
            try? User.remove()
            appState.loadUser()
        case .lockDoor:
            trigger(action: .lockDoor)
        case .pressBuzzer:
            trigger(action: .pressBuzzer)
        case .unlockDoor:
            trigger(action: .unlockDoor)
        case .unlatchDoor:
            trigger(action: .unlatchDoor)
        }
    }
}
