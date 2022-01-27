import Foundation

func PressBuzzer() async {
  let url = URL(string: secrets.buzzerUrl)!
  let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
  let (data, response) = try await URLSession.shared.data(for: request)
}
