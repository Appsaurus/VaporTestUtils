//
//  ResponseExtensions.swift
//  VaporTestUtils
//
//
//  Original source and copyright notice from: https://github.com/LiveUI/VaporTestTools
//
//	MIT License
//
//	Copyright (c) 2018 LiveUI
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import Foundation
@testable import Vapor
@testable import NIO

extension Response {

	/// Make a fake request
	private var fakeRequest: Request {
		let http = HTTPRequest(method: .GET, url: URL(string: "/")!)
		let req = Request(http: http, using: self)
		return req
	}

	/// Get header by it's name
	public func header(name: String) -> String? {
		let headerName = HTTPHeaderName(name)
		return header(name: headerName)
	}

	/// Get header by it's HTTPHeaderName representation
	public func header(name: HTTPHeaderName) -> String? {
		return http.headers[name].first
	}

	/// Size of the content
	public var contentSize: Int? {
		return content.container.http.body.data?.count
	}

	/// Get content string. Maximum of 0.5Mb of text will be returned
	public var contentString: String? {
		guard let data = try? content.container.http.body.consumeData(max: 500000, on: fakeRequest).wait() else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}

	/// Get content string with encoding. Maximum of 0.5Mb of text will be returned
	public func contentString(encoding: String.Encoding) -> String? {
		guard let data = try? content.container.http.body.consumeData(max: 500000, on: fakeRequest).wait() else {
			return nil
		}
		return String(data: data, encoding: encoding)
	}
}

//MARK: Test methods
extension Response {

	/// Test header value
	public func has(header name: HTTPHeaderName, value: String? = nil) -> Bool {
		guard let header = header(name: name) else {
			return false
		}

		if let value = value {
			// QUESTION: Do we want to be specific and use ==?
			return header.contains(value)
		}
		else {
			return true
		}
	}

	/// Test header value
	public func has(header name: String, value: String? = nil) -> Bool {
		let headerName = HTTPHeaderName(name)
		return has(header: headerName, value: value)
	}

	/// Test header Content-Type
	public func has(contentType value: String) -> Bool {
		let headerName = HTTPHeaderName("Content-Type")
		return has(header: headerName, value: value)
	}

	/// Test header Content-Length
	public func has(contentLength value: Int) -> Bool {
		let headerName = HTTPHeaderName("Content-Length")
		return has(header: headerName, value: String(value))
	}

	/// Test response status code
	public func has(statusCode value: HTTPStatus) -> Bool {
		return http.status.code == value.code
	}

	/// Test response status code and message
	public func has(statusCode value: HTTPStatus, message: String) -> Bool {
		return http.status.code == value.code && http.status.reasonPhrase == message
	}

	/// Test response content
	public func has(content value: String) -> Bool {
		return contentString == value
	}
}
