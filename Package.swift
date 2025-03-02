// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Slider",
    platforms: [
        .iOS(.v14)
    ],
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
    swiftLanguageModes: [.v6]
)
