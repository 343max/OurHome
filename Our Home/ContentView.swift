import SwiftUI

struct ContentView: View {
  @State private var showDoorOpenerAlert = false
  
  var body: some View {
    List() {
      Section("Haustür") {
        Button {
          print("was tapped")
        } label: {
          Label("Haustür öffnen", systemImage: "figure.walk")
        }
      }
      Section("Wohnungstür") {
        Button {
          showDoorOpenerAlert = true
        } label: {
          Label("Wohnungstür öffnen", systemImage: "lock").foregroundColor(.red)
        }.alert(isPresented: $showDoorOpenerAlert) {
          Alert(
            title: Text("Wohnungstür öffnen?"),
            message: Text("Wenn die Wohnungstür geöffnet wurde, kann sie nicht automatisch wieder geschlossen werden."),
            primaryButton: .default(Text("Abbrechen")) { showDoorOpenerAlert = false },
            secondaryButton: .destructive(Text("Wohnungstür öffnen")) { showDoorOpenerAlert = false })
        }
      }
      Section() {
        Button {
          print("was tapped")
        } label: {
          Label("Wohnungstür aufschließen", systemImage: "lock.open")
        }
        Button {
          print("was tapped")
        } label: {
          Label("Wohnungstür abschließen", systemImage: "lock")
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
