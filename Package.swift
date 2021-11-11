// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ACEDrawingView",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "ACEDrawingView",
            targets: ["ACEDrawingView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ACEDrawingView",
            path: "ACEDrawingView",
            resources: [.process("ACEDraggableText")]),
    ]
)
