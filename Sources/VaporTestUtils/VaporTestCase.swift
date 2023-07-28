//
//  VaporTestCase.swift
//  VaporTestUtils
//
//  Created by Brian Strobach on 12/6/17.
//

import XCTest
import XCTVapor
import SwiftTestUtils

public typealias AppConfigurer = (_ app: Application) throws -> Void

public enum TestInvocationPlatform: CaseIterable, Equatable {
    case macOS
    case tvOS
    case watchOS
    case iOS
    case linux
    case unknown
    static var current: TestInvocationPlatform {
#if os(macOS)
        return .macOS
#elseif os(tvOS)
        return .tvOS
#elseif os(watchOS)
        return .watchOS
#elseif os(iOS)
        return .iOS
#elseif os(Linux)
        return .linux
#else
        return .unknown
#endif
    }
}
open class VaporTestCase: XCTestCase {

    open lazy var loggingLevel: LoggingLevel = .none
    
    open var app: Application!
    
    open var applicationEnvironment: Environment {
        return .testing
    }
    
    open var skipInvocationInReleaseMode: Bool { false }
    
    open var validInvocationEnvironments: [Environment] {
        return [.development, .testing]
    }
    
    open var validInvocationPlatforms: [TestInvocationPlatform] {
        var cases = TestInvocationPlatform.allCases
        if let unknownIndex = TestInvocationPlatform.allCases.firstIndex(of: .unknown) {
            cases.remove(at: unknownIndex)
        }
        return cases
    }
    
    func skipInvalidEnvironments() throws {
        try skipUnlessPlatformEquals(equalsAny: validInvocationPlatforms)
        try skipUnlessEnvironmentEquals(equalsAny: validInvocationEnvironments)
        if skipInvocationInReleaseMode { try skipIfReleaseEnvironment() }
    }
    
    
    open var configurer: AppConfigurer{
        return { _ in }
    }

    open override func setUp() async throws {
        try skipInvalidEnvironments()
        try await super.setUp()
        app = try createApplication()
        try addConfiguration(to: app)
        try await afterAppConfiguration()
    }

    open override func tearDown() async throws {
        try skipInvalidEnvironments()
        try await super.tearDown()
        try await beforeAppShutdown()
        app.shutdown()
    }
    
    open func createApplication() throws -> Application {
        let app = Application(applicationEnvironment)
        try configurer(app)
        return app
    }
    
    open func afterAppConfiguration() async throws {}

    open func beforeAppShutdown() async throws {}

    open func addConfiguration(to app: Application) throws {
        try addRoutes(to: app.routes)
    }

    open func addRoutes(to router: Routes) throws {}

}

public enum LoggingLevel{
    case none, requests, responses, debug
}
extension VaporTestCase{
	open func log(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line){
		guard loggingLevel != .none else { return }
		let fileName = file.split(separator: "/").last!
		print("\n⏱ \(Date()) 👉 \(fileName).\(function) line \(line) 👇\n\n\(String(describing: message()))\n\n")
	}

	open func log(response: Response){
		switch loggingLevel {
		case .debug, .responses:
            log("RESPONSE:\n\(response)")
		default:
			return
		}
	}
}



extension XCTestCase {
    
    func skipIfPlatform(equalsAny environments: TestInvocationPlatform...) throws {
        try XCTSkipIf(TestInvocationPlatform.current.equalToAny(of: environments))
    }
    
    func skipIfPlatform(equalsAny environments: [TestInvocationPlatform]) throws {
        try XCTSkipIf(TestInvocationPlatform.current.equalToAny(of: environments))
    }

    func skipUnlessPlatformEquals(equalsAny environments: TestInvocationPlatform...) throws {
        try XCTSkipUnless(TestInvocationPlatform.current.equalToAny(of: environments))
    }
    
    func skipUnlessPlatformEquals(equalsAny environments: [TestInvocationPlatform]) throws {
        try XCTSkipUnless(TestInvocationPlatform.current.equalToAny(of: environments))
    }
    
    func skipIfEnvironment(equalsAny environments: Environment...) throws {
        try XCTSkipIf(Environment.detect().equalToAny(of: environments))
    }
    
    func skipIfEnvironment(equalsAny environments: [Environment]) throws {
        try XCTSkipIf(Environment.detect().equalToAny(of: environments))
    }

    func skipUnlessEnvironmentEquals(equalsAny environments: Environment...) throws {
        try XCTSkipUnless(Environment.detect().equalToAny(of: environments))
    }
    
    func skipUnlessEnvironmentEquals(equalsAny environments: [Environment]) throws {
        try XCTSkipUnless(Environment.detect().equalToAny(of: environments))
    }
    
    func skipIfReleaseEnvironment() throws {
        try XCTSkipIf(Environment.detect().isRelease)
    }
}

public extension VaporTestCase {
    var request: Request {
        Request(application: app, on: app.eventLoopGroup.next())
    }
}

extension VaporTestCase {
    var environment: Environment {
        return try! Environment.detect()
    }
}

fileprivate extension Equatable {
    
    func equalToAny(of items: [Self]) -> Bool {
        return items.contains(where: { (item) -> Bool in
            item == self
        })
    }
    
    func equalToAny(of items: Self...) -> Bool {
        return equalToAny(of: items)
    }
}
