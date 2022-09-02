// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "NodeEditor",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [.library(name: "NodeEditor", targets: ["NodeEditor"])],
    targets: [
        .target(name: "NodeEditor"),
        .testTarget(name: "NodeEditorTests", dependencies: ["NodeEditor"]),
    ]
)
