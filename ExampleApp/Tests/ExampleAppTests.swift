import ExampleApp
import XCTest
import VaporTestUtils

final class ExampleAppTests: VaporTestCase {

	static var allTests = [
		("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
		("testMyApp", testMyApp)
	]

	func testLinuxTestSuiteIncludesAllTests(){
		assertLinuxTestCoverage(tests: type(of: self).allTests)
	}

	override func setUp() {
		super.setUp()
		loggingLevel = .debug
	}

	override var booter: AppBooter{
		return ExampleApp.boot
	}
	override var configurer: AppConfigurer{
		return ExampleApp.configure
	}

	func testMyApp() throws {
		let response = try executeRequest(method: .GET, path: "testing-vapor-apps")
		XCTAssert(response.has(statusCode: .ok))
		XCTAssert(response.has(content: "is super easy"))
	}
}
