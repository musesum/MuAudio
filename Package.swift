// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MuAudio",
    platforms: [.iOS(.v17)],
    products: [.library(name: "MuAudio", targets: ["MuAudio"])],
    dependencies: [
        .package(url: "https://github.com/musesum/MuFlo.git", branch: "sync"),
        .package(url: "https://github.com/musesum/MuPeer.git", branch: "sync"),
        .package(url: "https://github.com/AudioKit/AudioKit.git", branch: "main")
    ],

    targets: [
        .target(name: "MuAudio",
        dependencies: [
            .product(name: "MuFlo", package: "MuFlo"),
            .product(name: "MuPeer", package: "MuPeer"),
            .product(name: "AudioKit", package: "AudioKit")
        ]),
        .testTarget(
            name: "MuAudioTests",
            dependencies: ["MuAudio"]),
    ]
)
