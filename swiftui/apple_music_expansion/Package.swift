// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppleMusicAlbumExpansion",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "AppleMusicAlbumExpansion",
            targets: ["AppleMusicAlbumExpansion"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "AppleMusicAlbumExpansion"
        ),
    ]
)
