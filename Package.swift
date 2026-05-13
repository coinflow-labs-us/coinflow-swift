// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CoinflowCardForm",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CoinflowCardForm",
            targets: ["CoinflowCardForm"]
        )
    ],
    targets: [
        .target(
            name: "CoinflowCardForm",
            path: "Sources/CoinflowCardForm"
        ),
        .testTarget(
            name: "CoinflowCardFormTests",
            dependencies: ["CoinflowCardForm"],
            path: "Tests/CoinflowCardFormTests"
        )
    ]
)
