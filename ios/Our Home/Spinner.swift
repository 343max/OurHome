import SwiftUI

#if os(watchOS)
struct Spinner: View {
  @Binding var spinning: Bool
  
  var body: some View {
    Text("🕝")
  }
}
#else
struct Spinner: UIViewRepresentable {
  @Binding var spinning: Bool
  
  func makeUIView(context: Context) -> UIActivityIndicatorView {
    let spinner = UIActivityIndicatorView()
    if spinning {
      spinner.startAnimating()
    }
    return spinner
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    if (spinning) {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}
#endif
