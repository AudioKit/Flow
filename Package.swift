// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Flow",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [.library(name: "Flow", targets: ["Flow"])],
    targets: [
        .target(name: "Flow"),
        .testTarget(name: "FlowTests", dependencies: ["Flow"]),
    ]
)
