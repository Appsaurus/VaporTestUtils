//
//  ExampleLinuxAppTests.swift
//  
//
//  Created by Brian Strobach on 7/28/23.
//

import ExampleApp
import XCTest
import XCTVapor
import XCTVaporExtensions

final class ExampleLinuxAppTests: VaporTestCase {
    
    override var validInvocationPlatforms: [TestInvocationPlatform] {
        return [.linux]
    }
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

