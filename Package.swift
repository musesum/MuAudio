// swift-tools-version: 5.7
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
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],

    targets: [
        .target(name: "MuAudio",
        dependencies: [
            .product(name: "MuPar", package: "MuPar"),
            .product(name: "MuFlo", package: "MuFlo"),
            .product(name: "MuPeer", package: "MuPeer"),
            .product(name: "AudioKit", package: "AudioKit"),
            .product(name: "Collections", package: "swift-collections")
        ]),
        .testTarget(
            name: "MuAudioTests",
            dependencies: ["MuAudio"]),
    ]
)
