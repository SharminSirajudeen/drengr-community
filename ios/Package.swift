// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Drengr",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13)],
    products: [
        .library(name: "Drengr", targets: ["Drengr"]),
    ],
    targets: [
        .target(name: "Drengr", path: "Sources/Drengr"),
        .testTarget(name: "DrengrTests", dependencies: ["Drengr"], path: "Tests/DrengrTests"),
    ]
)
