// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporTestUtils",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VaporTestUtils",
            targets: ["VaporTestUtils"]),
    ],
    dependencies: [
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VaporTestUtils",
            dependencies: ["SwiftTestUtils", "Vapor"]),
        .testTarget(
            name: "VaporTestUtilsTests",
            dependencies: ["VaporTestUtils"]),

		//Example App
		.target(name: "ExampleApp", dependencies: ["Vapor"], path: "./ExampleApp/App"),
		.testTarget(name: "ExampleAppTests", dependencies: ["ExampleApp", "VaporTestUtils"], path: "./ExampleApp/Tests")
    ]
)
