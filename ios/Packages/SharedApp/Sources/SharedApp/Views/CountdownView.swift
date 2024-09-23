import SwiftUI

private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

private func secondsToString(_ seconds: Int) -> String {
    let (_, m, s) = secondsToHoursMinutesSeconds(seconds)

    return String(format: "%d:%.2d", m, s)
}

struct CountdownView: View {
    let timeout: Date
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var remaining: String? = nil

    func updateRemaining() {
        let remainingSeconds = timeout.timeIntervalSinceNow
        remaining = remainingSeconds > 0 ? secondsToString(Int(remainingSeconds)) : nil
    }

    var body: some View {
        VStack {
            if let remaining {
                Text(remaining)
                    .font(.caption.monospacedDigit())
            }
        }
        .onReceive(timer) { _ in
            updateRemaining()
        }
        .onAppear {
            updateRemaining()
        }
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView(timeout: Date().addingTimeInterval(72))
    }
}
