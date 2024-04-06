// swift-tools-version: 5.9

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
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
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
