// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimeDuck",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "TimeDuck",
            targets: ["TimeDuck"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TimeDuck",
            path: "src"
        )
    ]
)
