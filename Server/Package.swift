// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Server",
  dependencies: [
    .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
    .package(name: "Verification", path: "../Verification")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .executableTarget(
      name: "Server",
      dependencies: ["Swifter", "Verification"]),
    .testTarget(
      name: "ServerTests",
      dependencies: ["Server"]),
  ]
)
