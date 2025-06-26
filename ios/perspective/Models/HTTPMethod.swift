import Foundation

/**
 * HTTP Method Enumeration
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles HTTP method definitions
 * - OCP: Easily extensible for new HTTP methods
 * - LSP: All methods are interchangeable where HTTPMethod is expected
 * - ISP: Focused interface for HTTP method handling
 * - DIP: Depends on Foundation string abstraction
 */

enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    
    /// Human-readable description of the HTTP method
    var description: String {
        switch self {
        case .GET:
            return "Retrieve data from server"
        case .POST:
            return "Send data to server to create resource"
        case .PUT:
            return "Send data to server to update/replace resource"
        case .PATCH:
            return "Send data to server to partially update resource"
        case .DELETE:
            return "Delete resource from server"
        case .HEAD:
            return "Retrieve headers only from server"
        case .OPTIONS:
            return "Get server capabilities for resource"
        }
    }
    
    /// Whether this HTTP method typically includes a request body
    var hasBody: Bool {
        switch self {
        case .GET, .HEAD, .DELETE, .OPTIONS:
            return false
        case .POST, .PUT, .PATCH:
            return true
        }
    }
    
    /// Whether this HTTP method is considered safe (no side effects)
    var isSafe: Bool {
        switch self {
        case .GET, .HEAD, .OPTIONS:
            return true
        case .POST, .PUT, .PATCH, .DELETE:
            return false
        }
    }
    
    /// Whether this HTTP method is idempotent (multiple identical requests have same effect)
    var isIdempotent: Bool {
        switch self {
        case .GET, .HEAD, .PUT, .DELETE, .OPTIONS:
            return true
        case .POST, .PATCH:
            return false
        }
    }
} 