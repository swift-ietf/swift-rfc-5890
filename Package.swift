// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-5890",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "RFC 5890",
            targets: ["RFC 5890"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-3492.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 5890",
            dependencies: [
                .product(name: "RFC 3492", package: "swift-rfc-3492")
            ]
        ),
        .testTarget(
            name: "RFC 5890 Tests",
            dependencies: [
                .target(name: "RFC 5890")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
