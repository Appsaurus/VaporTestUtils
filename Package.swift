// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporTestUtils",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VaporTestUtils",
            targets: ["VaporTestUtils"]),
    ],
    dependencies: [
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VaporTestUtils",
            dependencies: [.product(name: "SwiftTestUtils", package: "SwiftTestUtils"),
                           .product(name: "Vapor", package: "vapor"),
                           .product(name: "XCTVapor", package: "vapor"),]),
        .testTarget(
            name: "VaporTestUtilsTests",
            dependencies: ["VaporTestUtils"]),
        .target(name: "ExampleApp",  dependencies: [
            .product(name: "Vapor", package: "vapor")
        ],path: "./ExampleApp/App"),

        .testTarget(name: "ExampleAppTests", dependencies: [
            .target(name: "ExampleApp"),
            .target(name: "VaporTestUtils"),
            .product(name: "XCTVapor", package: "vapor")

        ], path: "./ExampleApp/Tests")

		//Example App
//		.target(name: "ExampleApp", dependencies: ["Vapor"], path: "./ExampleApp/App"),
//		.testTarget(name: "ExampleAppTests", dependencies: ["ExampleApp", "VaporTestUtils"], path: "./ExampleApp/Tests")
    ]
)
