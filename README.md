# swift-rfc-5890

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

IDNA terminology and the domain-name framework defined in RFC 5890.

## Standard Reference

- **RFC**: 5890
- **Title**: Internationalized Domain Names for Applications (IDNA): Definitions and Document Framework

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-5890.git", from: "0.1.2")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 5890", package: "swift-rfc-5890")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
