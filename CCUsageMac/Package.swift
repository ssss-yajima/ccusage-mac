// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CCUsageMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CCUsageMac",
            targets: ["CCUsageMac"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CCUsageMac",
            path: "Sources"
        ),
        .testTarget(
            name: "CCUsageMacTests",
            dependencies: ["CCUsageMac"],
            path: "Tests"
        )
    ]
)