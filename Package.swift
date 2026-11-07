// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Mirror",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Mirror"),
        .testTarget(name: "MirrorTests", dependencies: ["Mirror"]),
    ]
)
