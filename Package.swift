// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MuAudio",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MuAudio",
            targets: ["MuAudio"]),
    ],
    dependencies: [
        .package(url: "https://github.com/musesum/MuPar.git", from: "0.23.0"),
        .package(url: "https://github.com/musesum/MuFlo.git", from: "0.23.0"),
        .package(url: "https://github.com/musesum/MuPeer.git", from: "0.23.0"),
        //.package(url: "https://github.com/warpling/AudioKit.git", branch: "visionOS"),
        .package(path: "../AudioKit-visionOS"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],

    targets: [
        .target(name: "MuAudio",
        dependencies: [
            .product(name: "MuPar", package: "MuPar"),
            .product(name: "MuFlo", package: "MuFlo"),
            .product(name: "MuPeer", package: "MuPeer"),
            .product(name: "AudioKit", package: "AudioKit-visionOS"),
            .product(name: "Collections", package: "swift-collections")
        ]),
        .testTarget(
            name: "MuAudioTests",
            dependencies: ["MuAudio"]),
    ]
)
