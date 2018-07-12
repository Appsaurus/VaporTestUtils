import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("testing-vapor-apps") { req in
        return try "is super easy".encode(for: req)
    }
}
