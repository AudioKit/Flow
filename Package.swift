// swift-tools-version: 5.5

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
