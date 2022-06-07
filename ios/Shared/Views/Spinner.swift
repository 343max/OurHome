import SwiftUI

#if os(watchOS)
  struct Spinner: View {
    @Binding var spinning: Bool
    @State private var scale: Double = 1.0

    var body: some View {
      Circle()
        .fill(.gray)
        .frame(width: 12, height: 12, alignment: .center)
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
        .onAppear {
          scale = 0.5
        }
    }
  }
#else
  struct Spinner: UIViewRepresentable {
    @Binding var spinning: Bool

    func makeUIView(context _: Context) -> UIActivityIndicatorView {
      let spinner = UIActivityIndicatorView()
      if spinning {
        spinner.startAnimating()
      }
      return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context _: Context) {
      if spinning {
        uiView.startAnimating()
      } else {
        uiView.stopAnimating()
      }
    }
  }
#endif
