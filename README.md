# VaporTestUtils
![Swift](http://img.shields.io/badge/swift-4.1-brightgreen.svg)
![Vapor](http://img.shields.io/badge/vapor-3.0-brightgreen.svg)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
![License](http://img.shields.io/badge/license-MIT-CCCCCC.svg)

## Installation

**VaporTestUtils** is available through [Swift Package Manager](https://swift.org/package-manager/). To install, simply add the following line to the dependencies in your Package.swift file.

```swift
let package = Package(
    name: "YourProject",
    dependencies: [
        ...
        .package(url: "https://github.com/Appsaurus/VaporTestUtils", from: "1.0.0"),
    ],
    targets: [
      .testTarget(name: "YourApp", dependencies: ["VaporTestUtils", ... ])
    ]
)
        
```
## Usage
Check the app included in this project for a complete example. Here are some of the basics:

**1. Import the library**

```swift
import XCTVaporExtensions
```

**2. Setup your test case**

Create a test case inheriting from `VaporTestCase`. Override computed properties `booter` and `configurer` and return the corresponding `boot` and `configure` functions from your app. Then, just start executing requests. Pretty simple stuff.

```swift
final class ExampleAppTests: VaporTestCase {

	static var allTests = [
		("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
		("testMyApp", testMyApp)
	]

	func testLinuxTestSuiteIncludesAllTests(){
		assertLinuxTestCoverage(tests: type(of: self).allTests)
	}

	override var booter: AppBooter{
		return ExampleApp.boot
	}
	
	override var configurer: AppConfigurer{
		return ExampleApp.configure
	}
	
	override func setUp() {
		super.setUp()
		loggingLevel = .debug //This is optional. Logs all requests and responses to the console.
	}

	func testMyApp() throws {
		let response = try executeRequest(method: .GET, path: "testing-vapor-apps")
		XCTAssert(response.has(statusCode: .ok))
		XCTAssert(response.has(content: "is super easy"))
	}
}
```
## Acknowledgements

Some extension methods were blatantly borrowed from LiveUI's [VaporTestTools](https://github.com/LiveUI/VaporTestTools). You should also check their library out as it serves a similar purpose (and might be even better).

## Contributing

We would love you to contribute to **VaporTestUtils**, check the [CONTRIBUTING](https://github.com/Appsaurus/VaporTestUtils/blob/master/CONTRIBUTING.md) file for more info.

## License

**VaporTestUtils** is available under the MIT license. See the [LICENSE](https://github.com/Appsaurus/VaporTestUtils/blob/master/LICENSE.md) file for more info.
