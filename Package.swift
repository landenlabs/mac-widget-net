// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mac-widget-net",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "mac-widget-net",
            path: "Sources/mac-widget-net"
        )
    ]
)
