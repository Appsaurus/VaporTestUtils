// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCTVaporExtensions",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "XCTVaporExtensions",
            targets: ["XCTVaporExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Appsaurus/SwiftTestUtils", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "XCTVaporExtensions",
            dependencies: [.product(name: "SwiftTestUtils", package: "SwiftTestUtils"),
                           .product(name: "Vapor", package: "vapor"),
                           .product(name: "XCTVapor", package: "vapor")]),
        .testTarget(
            name: "XCTVaporExtensionsTests",
            dependencies: ["XCTVaporExtensions"]),
        .target(name: "ExampleApp",  dependencies: [
            .product(name: "Vapor", package: "vapor")
        ],path: "./ExampleApp/App"),

        .testTarget(name: "ExampleAppTests", dependencies: [
            .target(name: "ExampleApp"),
            .target(name: "XCTVaporExtensions"),
            .product(name: "XCTVapor", package: "vapor")

        ], path: "./ExampleApp/Tests")
    ]
)
