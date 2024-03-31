// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KuwaharaFilter",
    platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "KuwaharaFilter",
            targets: ["KuwaharaFilter"]),
    ],
    targets: [
        .target(
            name: "KuwaharaFilter", resources: [.process("Resources/blackSquare.jpg")],
            cSettings: [.define("CI_SILENCE_GL_DEPRECATION")]
        ),
        .testTarget(
            name: "KuwaharaFilterTests",
            dependencies: ["KuwaharaFilter"],
            swiftSettings: [.define("CI_SILENCE_GL_DEPRECATION")]
        ),
    ]
)
