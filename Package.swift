// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "NodeEditor",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [.library(name: "NodeEditor", targets: ["NodeEditor"])],
    dependencies: [.package(url: "https://github.com/audulus/vger", branch: "main")],
    targets: [
        .target(name: "NodeEditor", dependencies: ["vger"]),
        .testTarget(name: "NodeEditorTests", dependencies: ["NodeEditor"]),
    ]
)
