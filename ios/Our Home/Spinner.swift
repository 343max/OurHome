import SwiftUI

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
