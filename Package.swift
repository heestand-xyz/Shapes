// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Shapes",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Shapes",
            targets: ["Shapes"]),
    ],
    targets: [
        .target(
            name: "Shapes",
            dependencies: []),
    ]
)
