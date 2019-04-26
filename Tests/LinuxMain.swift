import XCTest

import ExampleAppTests
import VaporTestUtilsTests

var tests = [XCTestCaseEntry]()
tests += ExampleAppTests.__allTests()
tests += VaporTestUtilsTests.__allTests()

XCTMain(tests)
