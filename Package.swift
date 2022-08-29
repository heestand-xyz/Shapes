// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Shapes",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
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
