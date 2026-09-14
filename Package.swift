// swift-tools-version: 6.4

import PackageDescription

/// Features that become the default in the Swift 7 language mode. Adopting them now keeps the
/// library compiling unchanged when that mode ships.
let swift7UpcomingFeatures: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
]

let package = Package(
    name: "Slider",
    platforms: [
        .iOS(.v18)
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
            dependencies: [],
            swiftSettings: swift7UpcomingFeatures),
        .testTarget(
            name: "SliderTests",
            dependencies: ["Slider"]),
    ],
    swiftLanguageModes: [.v6]
)
