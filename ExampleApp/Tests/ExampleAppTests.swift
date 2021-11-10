import ExampleApp
import XCTest
import XCTVapor
import VaporTestUtils

final class ExampleAppTests: VaporTestCase {

	override var configurer: AppConfigurer{
		return ExampleApp.configure
	}

	func testMyApp() throws {
        try app.test(.GET, "testing-vapor-apps") { response in
            XCTAssertEqual(response.status, .ok)            
            XCTAssert(response.has(content: "is super easy"))
        }
	}
}
