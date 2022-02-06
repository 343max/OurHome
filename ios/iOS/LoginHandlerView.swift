import SwiftUI

struct LoginHandlerView<Content: View>: View {
  @StateObject private var session = try! Session()
  var content: () -> Content

  var body: some View {
    let showLoggingInSheet = Binding(
      get: { session.loggedInState == .loggingIn },
      set: { _ in }
    )
    
    let showLoggedOutSheet = Binding(
      get: { session.loggedInState == .loggedOut },
      set: { _ in }
    )

    content()
      .sheet(isPresented: showLoggedOutSheet)
    {
      LoggedOutView()
    }
      .sheet(isPresented: showLoggingInSheet)
    {
      Text("logging in").interactiveDismissDisabled(true)
    }
      .onOpenURL
    { url in
      Task {
        do {
          try await session.login(url: url)
        }
      }
    }
  }
}

struct LoginHandlerView_Previews: PreviewProvider {
  static var previews: some View {
    LoginHandlerView() { Text("Content") }
  }
}
