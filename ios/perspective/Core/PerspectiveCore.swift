import Foundation
import UIKit
import Combine
import Network

/**
 * Perspective Core Module
 * 
 * Centralized import and type resolution for the Perspective app
 * Ensures proper module visibility across all components
 * 
 * ARCHITECTURE NOTES:
 * - This file establishes the core module structure
 * - Import this in any file that needs cross-module type access
 * - Provides consistent foundation for SOLID principles implementation
 */

// MARK: - Core Type Aliases

public typealias APIResult<T> = Result<T, APIError>
public typealias NetworkPublisher<T> = AnyPublisher<T, APIError>

// MARK: - Global Constants

public enum PerspectiveConstants {
    public static let apiVersion = "v1"
    public static let maxRetryAttempts = 3
    public static let requestTimeoutInterval: TimeInterval = 30
    public static let cacheExpirationInterval: TimeInterval = 3600 // 1 hour
}

// MARK: - Common Protocols

public protocol Injectable {
    associatedtype Dependencies
    init(dependencies: Dependencies)
}

public protocol Cacheable: Codable {
    var cacheKey: String { get }
    var expiresAt: Date? { get }
}

public protocol NetworkRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

// MARK: - Notification Names

public extension Notification.Name {
    static let authTokenExpired = Notification.Name("authTokenExpired")
    static let userNeedsToReauthenticate = Notification.Name("userNeedsToReauthenticate")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let challengeCompleted = Notification.Name("challengeCompleted")
    static let userProfileUpdated = Notification.Name("userProfileUpdated")
}

// MARK: - Error Extensions

public extension Error {
    var localizedTitle: String {
        if let apiError = self as? APIError {
            return apiError.errorDescription ?? "API Error"
        }
        return "Error"
    }
}

// MARK: - Debug Helpers

#if DEBUG
public enum DebugLogger {
    public static func log(_ message: String, category: String = "Perspective") {
        print("[\(category)] \(message)")
    }
    
    public static func logError(_ error: Error, context: String = "") {
        print("🚨 ERROR [\(context)]: \(error.localizedDescription)")
    }
    
    public static func logNetwork(_ request: URLRequest) {
        print("🌐 REQUEST: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "Unknown")")
    }
}
#endif 