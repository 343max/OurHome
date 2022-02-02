func appVersion() -> String {
  let versionString: String = try! Configuration.value(for: "CFBundleShortVersionString")
  let buildNumber: String = try! Configuration.value(for: "CFBundleVersion")
  return "\(versionString) Build: \(buildNumber)"
}
