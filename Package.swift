// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc5890: Self = "RFC 5890"
}

extension Target.Dependency {
    static var rfc5890: Self { .target(name: .rfc5890) }
    static var rfc3492: Self { .product(name: "RFC 3492", package: "swift-rfc-3492") }
}

let package = Package(
    name: "swift-rfc-5890",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "RFC 5890",
            targets: ["RFC 5890"]
        )
    ],
    dependencies: [
        .package(path: "../swift-rfc-3492")
    ],
    targets: [
        .target(
            name: "RFC 5890",
            dependencies: [
                .rfc3492
            ]
        ),
        .testTarget(
            name: "RFC 5890 Tests",
            dependencies: [
                "RFC 5890",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
