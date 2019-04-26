//
//  VaporTestCase.swift
//  ServasaurusTests
//
//  Created by Brian Strobach on 12/6/17.
//

import Foundation
import XCTest
@testable import HTTP
@testable import Vapor
import SwiftTestUtils


public enum LoggingLevel{
	case none, requests, responses, debug
}

open class VaporTestCase: BaseTestCase{
	open lazy var loggingLevel: LoggingLevel = .none

	open var config: Config = Config.default()
	open var environment: Environment = try! Environment.detect()
	open var services: Services = Services.default()

	open var booter: AppBooter{
		return boot
	}
	open var configurer: AppConfigurer{
		return configure
	}
	open var defaultRequestHeaders: [String : String] = [:]

	public static var persistApplicationBetweenTests: Bool = false
	public static var persistedApplication: Application!

	private var _persistApplicationBetweenTests: Bool {
		return type(of: self).persistApplicationBetweenTests
	}
	private var _persistedApplication: Application!{
		get{
			if type(of: self).persistedApplication == nil{
				type(of: self).persistedApplication = try! self.createApplication()
			}
			return type(of: self).persistedApplication
		}
		set{ type(of: self).persistedApplication = newValue }
	}

	open var app: Application{
		get{
			return _persistedApplication
		}
		set{
			_persistedApplication = newValue
		}
	}

	open var router: Router!

	open var request: Request{
		return Request(using: app)
	}

	//MARK: Setup & Teardown
	open override func setUp() {
		super.setUp()
		if _persistedApplication == nil || !_persistApplicationBetweenTests{
			_persistedApplication = try! createApplication()
		}
	}

	open override func tearDown() {
		super.tearDown()
		if !_persistApplicationBetweenTests{
			_persistedApplication = nil
		}
	}

	open func createApplication() throws -> Application! {
		try configurer(&config, &environment, &services)
		let app = try Application(
			config: config,
			environment: environment,
			services: services
		)
		router = try app.make(Router.self)
		try routes(router)
		try configure(router: router)
		try booter(app)
		didBoot(app)
		return app
	}

	//MARK: Configuration & Booting
	open func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

		//Register services and providers first
		try register(&services)

		// Register routes to the router
		let router = EngineRouter.default()
		try routes(router)
		services.register(router, as: Router.self)

		// Register middleware
		var middlewares = MiddlewareConfig() // Create _empty_ middleware config
		configure(middlewares: &middlewares)
		services.register(middlewares)

		// Configure databases
		var databases = DatabasesConfig()
		try configure(databases: &databases)
		services.register(databases)

	}

	open func register(_ services: inout Services) throws {

	}

	open func configure(databases: inout DatabasesConfig) throws{

	}

	open func configure(middlewares: inout MiddlewareConfig){

	}

	open func routes(_ router: Router) throws {

	}


	/// Hook for adding addition configuration to your router that is not defined in the application's default setup.
	///
	/// - Parameter router: the router to configure.
	/// - Throws: An error is configuration fails.
	open func configure(router: Router) throws{

	}

	open func boot(_ app: Application) throws{

	}


	open func didBoot(_ app: Application){

	}

	//MARK: Request Convenience methods
	open func buildRequest(headers: [String: String] = [:],
						   method: HTTPMethod,
						   body: HTTPBody? = nil,
						   path: String,
						   queryItems: [URLQueryItem]? = nil) throws -> Request{

		let headers = headers.merging(defaultRequestHeaders) { (lhs, rhs) -> String in
			return lhs
		}
		guard let urlComponents = URLComponents(string: path)  else { throw Abort(.badRequest) }
		var url = urlComponents
		url.queryItems = queryItems
		guard let urlString = url.url?.absoluteString else { throw Abort(.badRequest) }
		let req: Request = request
		req.http.method = method
		req.http.urlString = urlString
		req.http.headers = convertToHTTPHeaders(headers)
		if let body = body {
			req.http.body = body.convertToHTTPBody()
		}

		return req
	}

	@discardableResult
	open func executeRequest(headers: [String: String] = [:],
							 method: HTTPMethod,
							 body: HTTPBody? = nil,
							 path: String,
							 queryItems: [URLQueryItem]? = nil) throws -> Response{

		let request = try buildRequest(headers: headers, method: method, body: body, path: path, queryItems: queryItems)
		log(request: request)
		let response = try respond(to: request)
		log(response: response)
		return response
	}

	/// Respond to HTTPRequest
	open func respond(to request: Request) throws -> Response {
		let responder = try! app.make(Responder.self)
		return try responder.respond(to: request).wait()
	}
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
			log("RESPONSE:\n\(response.http)")
		default:
			return
		}
	}

	open func log(request: Request){
		switch loggingLevel {
		case .debug, .requests:
			log("REQUEST:\n\(request.http)")
		default:
			return
		}
	}
}

fileprivate func convertToHTTPHeaders(_ dictionary: [String : String]) -> HTTPHeaders {
	var headersObject = HTTPHeaders()
	for key in dictionary.keys {
		let value = dictionary[key]!
		headersObject.replaceOrAdd(name: key, value: value)
	}
	return headersObject
}

