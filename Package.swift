// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "KeyWindow",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v14),
        .macOS(SupportedPlatform.MacOSVersion.v11)
    ],
    products: [
        .library(
            name: "KeyWindow",
            targets: ["KeyWindow"]
        )
    ],
    targets: [
        .target(
            name: "KeyWindow",
            dependencies: []
        ),
        .testTarget(name: "KeyWindowTests", dependencies: ["KeyWindow"])
    ]
)
