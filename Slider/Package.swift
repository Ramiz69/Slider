// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Slider",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Slider",
            targets: ["Slider"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Slider",
            dependencies: []),
        .testTarget(
            name: "SliderTests",
            dependencies: ["Slider"]),
    ],
    swiftLanguageVersions: [.v5]
)
