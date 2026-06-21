// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DynamicWeatherAnimation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "DynamicWeatherAnimation",
            targets: ["DynamicWeatherAnimation"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "DynamicWeatherAnimation"
        ),
    ]
)
