// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KuwaharaFilter",
    products: [
        .library(
            name: "KuwaharaFilter",
            targets: ["KuwaharaFilter"]),
    ],
    targets: [
        .target(
            name: "KuwaharaFilter", resources: [.process("Resources/blackSquare.jpg")]),
        .testTarget(
            name: "KuwaharaFilterTests",
            dependencies: ["KuwaharaFilter"]
        ),
    ]
)
