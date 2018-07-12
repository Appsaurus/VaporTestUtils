//
//  Typealiases.swift
//  VaporTestUtils
//
//  Created by Brian Strobach on 5/21/18.
//

import Foundation
import Vapor

public typealias AppConfigurer = (
	_ config: inout Config,
	_ env: inout Environment,
	_ services: inout Services
	) throws -> Void

public typealias AppBooter = (_ app: Application) throws  -> Void
