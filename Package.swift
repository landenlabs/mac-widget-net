// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacWidgetNet",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MacWidgetNet",
            path: "Sources/MacWidgetNet",
            resources: [.process("Resources")]
        )
    ]
)
