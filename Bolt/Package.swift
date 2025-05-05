// swift-tools-version: 6.0

import PackageDescription

let package: Package = Package(
    name: "Bolt",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "Bolt",
            targets: [
                "Bolt"
            ]),
        .library(
            name: "Editor",
            targets: [
                "Editor"
            ])
    ],
    targets: [
        .target(
            name: "Bolt",
            dependencies: [
                "Editor"
            ]),
        .testTarget(
            name: "BoltTests",
            dependencies: [
                "Bolt"
            ]),
        .target(name: "Editor"),
        .testTarget(
            name: "EditorTests",
            dependencies: [
                "Editor"
            ])
    ])
