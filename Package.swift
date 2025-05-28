// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MuAudio",
    platforms: [.iOS(.v17),
                .macOS(.v11)],
    products: [.library(name: "MuAudio", targets: ["MuAudio"])],
    dependencies: [
        .package(url: "https://github.com/musesum/MuFlo.git", branch: "main"),
        .package(url: "https://github.com/musesum/MuPeers.git", branch: "main"),
        .package(url: "https://github.com/AudioKit/AudioKit.git", branch: "main")
    ],

    targets: [
        .target(name: "MuAudio",
        dependencies: [
            .product(name: "MuFlo", package: "MuFlo"),
            .product(name: "MuPeers", package: "MuPeers"),
            .product(name: "AudioKit", package: "AudioKit")
        ]),
        .testTarget(
            name: "MuAudioTests",
            dependencies: ["MuAudio"]),
    ]
)
