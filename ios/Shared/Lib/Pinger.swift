import Foundation

class Pinger {
  private var isHostReachable = false
  private var shouldStop = false
  private let url: URL
  private let update: (Bool) -> Void
  
  init(url: URL, update: @escaping (Bool) -> Void) {
    self.url = url
    self.update = update
    checkReachability()
  }
  
  private func checkReachability() {
    var request = URLRequest(url: url, timeoutInterval: 1.0)
    request.httpMethod = "HEAD"
    
    URLSession.shared.dataTask(with: request) { (_, response, error) in
      self.isHostReachable = (response as? HTTPURLResponse)?.statusCode == 200
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        if !self.shouldStop {
          self.checkReachability()
        }
      }
      
      self.update(self.isHostReachable)
    }.resume()
  }
  
  deinit {
    shouldStop = true
  }
}
