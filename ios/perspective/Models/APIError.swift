import Foundation

/**
 * API Error Handling System
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles API error definitions and mapping
 * - OCP: Extensible for new error types
 * - LSP: All errors conform to Error protocol
 * - ISP: Focused interface for error handling
 * - DIP: Depends on Foundation abstractions
 */

// MARK: - API Error Types

/**
 * Comprehensive API Error taxonomy following SOLID principles
 * 
 * Single Responsibility: Each error type represents a specific failure mode
 * Open/Closed: Easy to extend with new error types without modification
 * Liskov Substitution: All errors conform to Error protocol consistently
 * Interface Segregation: Focused, specific error types
 * Dependency Inversion: Abstracts away implementation details
 */
public enum APIError: Error, LocalizedError, Equatable {
    
    // MARK: - Authentication Errors
    case unauthorized
    case invalidCredentials
    case tokenExpired
    case tokenInvalid
    case refreshTokenExpired
    case authenticationRequired
    case forbidden(String)
    case twoFactorRequired
    case passwordChangeRequired
    case accountLocked(String)
    case loginAttemptsExceeded
    
    // MARK: - Validation Errors
    case badRequest(String)
    case validationError(String)
    case missingRequiredField(String)
    case invalidFieldFormat(String, field: String)
    case fieldTooLong(String, field: String, maxLength: Int)
    case fieldTooShort(String, field: String, minLength: Int)
    case invalidEmailFormat
    case invalidPasswordFormat
    case passwordTooWeak
    case usernameUnavailable
    case emailAlreadyExists
    
    // MARK: - Resource Errors
    case notFound(String)
    case resourceNotFound(String, resourceType: String)
    case conflict(String)
    case resourceAlreadyExists(String, resourceType: String)
    case resourceLocked(String)
    case resourceDeleted(String)
    case resourceUnavailable(String)
    
    // MARK: - Network Errors
    case networkError(Error)
    case noInternetConnection
    case timeout
    case invalidURL
    case invalidResponse
    case rateLimited(retryAfter: TimeInterval?)
    case serviceUnavailable(String)
    
    // MARK: - Server Errors
    case serverError(String)
    case internalServerError
    case badGateway
    case serviceTemporarilyUnavailable
    case maintenanceMode(String)
    case databaseError(String)
    case thirdPartyServiceError(String, service: String)
    
    // MARK: - Data Processing Errors
    case decodingError
    case encodingError
    case dataCorrupted(String)
    case unsupportedDataFormat(String)
    case dataTooLarge(String, maxSize: Int)
    
    // MARK: - Business Logic Errors
    case insufficientPermissions(String)
    case quotaExceeded(String, limit: Int)
    case featureNotEnabled(String)
    case subscriptionRequired(String)
    case subscriptionExpired
    case paymentRequired(String)
    case trialExpired
    
    // MARK: - System Errors
    case configurationError(String)
    case systemOverloaded
    case diskSpaceFull
    case memoryError
    case fileSystemError(String)
    
    // MARK: - Generic/Unknown Errors
    case unknownError(Int, String)
    case customError(String, code: String?)
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        // Authentication Errors
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .invalidCredentials:
            return "Invalid username or password."
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .tokenInvalid:
            return "Invalid authentication token."
        case .refreshTokenExpired:
            return "Your session has expired. Please log in again."
        case .authenticationRequired:
            return "Authentication is required to access this resource."
        case .forbidden(let message):
            return message.isEmpty ? "Access forbidden." : message
        case .twoFactorRequired:
            return "Two-factor authentication is required."
        case .passwordChangeRequired:
            return "You must change your password before continuing."
        case .accountLocked(let message):
            return message.isEmpty ? "Account is temporarily locked." : message
        case .loginAttemptsExceeded:
            return "Too many login attempts. Please try again later."
            
        // Validation Errors
        case .badRequest(let message):
            return message.isEmpty ? "Invalid request." : message
        case .validationError(let message):
            return message.isEmpty ? "Validation failed." : message
        case .missingRequiredField(let field):
            return "Required field '\(field)' is missing."
        case .invalidFieldFormat(let message, let field):
            return "Invalid format for field '\(field)': \(message)"
        case .fieldTooLong(let message, let field, let maxLength):
            return "Field '\(field)' exceeds maximum length of \(maxLength) characters: \(message)"
        case .fieldTooShort(let message, let field, let minLength):
            return "Field '\(field)' must be at least \(minLength) characters: \(message)"
        case .invalidEmailFormat:
            return "Please enter a valid email address."
        case .invalidPasswordFormat:
            return "Password format is invalid."
        case .passwordTooWeak:
            return "Password is too weak. Please choose a stronger password."
        case .usernameUnavailable:
            return "Username is not available."
        case .emailAlreadyExists:
            return "An account with this email address already exists."
            
        // Resource Errors
        case .notFound(let message):
            return message.isEmpty ? "Resource not found." : message
        case .resourceNotFound(let message, let resourceType):
            return "\(resourceType) not found: \(message)"
        case .conflict(let message):
            return message.isEmpty ? "Conflict occurred." : message
        case .resourceAlreadyExists(let message, let resourceType):
            return "\(resourceType) already exists: \(message)"
        case .resourceLocked(let message):
            return "Resource is locked: \(message)"
        case .resourceDeleted(let message):
            return "Resource has been deleted: \(message)"
        case .resourceUnavailable(let message):
            return "Resource is temporarily unavailable: \(message)"
            
        // Network Errors
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection available."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
            } else {
                return "Rate limit exceeded. Please try again later."
            }
        case .serviceUnavailable(let message):
            return message.isEmpty ? "Service is temporarily unavailable." : message
            
        // Server Errors
        case .serverError(let message):
            return message.isEmpty ? "Server error occurred." : message
        case .internalServerError:
            return "Internal server error. Please try again later."
        case .badGateway:
            return "Bad gateway. Please try again later."
        case .serviceTemporarilyUnavailable:
            return "Service is temporarily unavailable."
        case .maintenanceMode(let message):
            return message.isEmpty ? "Service is under maintenance." : message
        case .databaseError(let message):
            return "Database error: \(message)"
        case .thirdPartyServiceError(let message, let service):
            return "\(service) service error: \(message)"
            
        // Data Processing Errors
        case .decodingError:
            return "Failed to process server response."
        case .encodingError:
            return "Failed to encode request data."
        case .dataCorrupted(let message):
            return "Data is corrupted: \(message)"
        case .unsupportedDataFormat(let format):
            return "Unsupported data format: \(format)"
        case .dataTooLarge(let message, let maxSize):
            return "Data too large (max \(maxSize) bytes): \(message)"
            
        // Business Logic Errors
        case .insufficientPermissions(let message):
            return message.isEmpty ? "Insufficient permissions." : message
        case .quotaExceeded(let message, let limit):
            return "Quota exceeded (limit: \(limit)): \(message)"
        case .featureNotEnabled(let feature):
            return "Feature '\(feature)' is not enabled."
        case .subscriptionRequired(let message):
            return message.isEmpty ? "Subscription required." : message
        case .subscriptionExpired:
            return "Your subscription has expired."
        case .paymentRequired(let message):
            return message.isEmpty ? "Payment required." : message
        case .trialExpired:
            return "Your trial period has expired."
            
        // System Errors
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .systemOverloaded:
            return "System is overloaded. Please try again later."
        case .diskSpaceFull:
            return "Insufficient disk space."
        case .memoryError:
            return "Memory error occurred."
        case .fileSystemError(let message):
            return "File system error: \(message)"
            
        // Generic/Unknown Errors
        case .unknownError(let statusCode, let message):
            return "Unknown error (HTTP \(statusCode)): \(message)"
        case .customError(let message, _):
            return message
        }
    }
    
    // MARK: - Error Code
    
    public var errorCode: String {
        switch self {
        // Authentication Errors
        case .unauthorized: return "UNAUTHORIZED"
        case .invalidCredentials: return "INVALID_CREDENTIALS"
        case .tokenExpired: return "TOKEN_EXPIRED"
        case .tokenInvalid: return "TOKEN_INVALID"
        case .refreshTokenExpired: return "REFRESH_TOKEN_EXPIRED"
        case .authenticationRequired: return "AUTHENTICATION_REQUIRED"
        case .forbidden: return "FORBIDDEN"
        case .twoFactorRequired: return "TWO_FACTOR_REQUIRED"
        case .passwordChangeRequired: return "PASSWORD_CHANGE_REQUIRED"
        case .accountLocked: return "ACCOUNT_LOCKED"
        case .loginAttemptsExceeded: return "LOGIN_ATTEMPTS_EXCEEDED"
            
        // Validation Errors
        case .badRequest: return "BAD_REQUEST"
        case .validationError: return "VALIDATION_ERROR"
        case .missingRequiredField: return "MISSING_REQUIRED_FIELD"
        case .invalidFieldFormat: return "INVALID_FIELD_FORMAT"
        case .fieldTooLong: return "FIELD_TOO_LONG"
        case .fieldTooShort: return "FIELD_TOO_SHORT"
        case .invalidEmailFormat: return "INVALID_EMAIL_FORMAT"
        case .invalidPasswordFormat: return "INVALID_PASSWORD_FORMAT"
        case .passwordTooWeak: return "PASSWORD_TOO_WEAK"
        case .usernameUnavailable: return "USERNAME_UNAVAILABLE"
        case .emailAlreadyExists: return "EMAIL_ALREADY_EXISTS"
            
        // Resource Errors
        case .notFound: return "NOT_FOUND"
        case .resourceNotFound: return "RESOURCE_NOT_FOUND"
        case .conflict: return "CONFLICT"
        case .resourceAlreadyExists: return "RESOURCE_ALREADY_EXISTS"
        case .resourceLocked: return "RESOURCE_LOCKED"
        case .resourceDeleted: return "RESOURCE_DELETED"
        case .resourceUnavailable: return "RESOURCE_UNAVAILABLE"
            
        // Network Errors
        case .networkError: return "NETWORK_ERROR"
        case .noInternetConnection: return "NO_INTERNET_CONNECTION"
        case .timeout: return "TIMEOUT"
        case .invalidURL: return "INVALID_URL"
        case .invalidResponse: return "INVALID_RESPONSE"
        case .rateLimited: return "RATE_LIMITED"
        case .serviceUnavailable: return "SERVICE_UNAVAILABLE"
            
        // Server Errors
        case .serverError: return "SERVER_ERROR"
        case .internalServerError: return "INTERNAL_SERVER_ERROR"
        case .badGateway: return "BAD_GATEWAY"
        case .serviceTemporarilyUnavailable: return "SERVICE_TEMPORARILY_UNAVAILABLE"
        case .maintenanceMode: return "MAINTENANCE_MODE"
        case .databaseError: return "DATABASE_ERROR"
        case .thirdPartyServiceError: return "THIRD_PARTY_SERVICE_ERROR"
            
        // Data Processing Errors
        case .decodingError: return "DECODING_ERROR"
        case .encodingError: return "ENCODING_ERROR"
        case .dataCorrupted: return "DATA_CORRUPTED"
        case .unsupportedDataFormat: return "UNSUPPORTED_DATA_FORMAT"
        case .dataTooLarge: return "DATA_TOO_LARGE"
            
        // Business Logic Errors
        case .insufficientPermissions: return "INSUFFICIENT_PERMISSIONS"
        case .quotaExceeded: return "QUOTA_EXCEEDED"
        case .featureNotEnabled: return "FEATURE_NOT_ENABLED"
        case .subscriptionRequired: return "SUBSCRIPTION_REQUIRED"
        case .subscriptionExpired: return "SUBSCRIPTION_EXPIRED"
        case .paymentRequired: return "PAYMENT_REQUIRED"
        case .trialExpired: return "TRIAL_EXPIRED"
            
        // System Errors
        case .configurationError: return "CONFIGURATION_ERROR"
        case .systemOverloaded: return "SYSTEM_OVERLOADED"
        case .diskSpaceFull: return "DISK_SPACE_FULL"
        case .memoryError: return "MEMORY_ERROR"
        case .fileSystemError: return "FILE_SYSTEM_ERROR"
            
        // Generic/Unknown Errors
        case .unknownError: return "UNKNOWN_ERROR"
        case .customError(_, let code): return code ?? "CUSTOM_ERROR"
        }
    }
}

// MARK: - Factory Methods

public extension APIError {
    
    /// Creates an APIError from an HTTP response and data
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - data: Response data
    /// - Returns: Appropriate APIError
    static func fromHTTPResponse(statusCode: Int, data: Data) -> APIError {
        // Fall back to status code mapping with message from data
        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        return fromStatusCode(statusCode, message: message)
    }
    
    /// Creates an APIError from an HTTP status code
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - message: Error message
    /// - Returns: Appropriate APIError
    static func fromStatusCode(_ statusCode: Int, message: String) -> APIError {
        switch statusCode {
        case 400:
            return .badRequest(message)
        case 401:
            return .unauthorized
        case 403:
            return .forbidden(message)
        case 404:
            return .notFound(message)
        case 409:
            return .conflict(message)
        case 422:
            return .validationError(message)
        case 429:
            return .rateLimited(retryAfter: nil)
        case 500:
            return .internalServerError
        case 502:
            return .badGateway
        case 503:
            return .serviceTemporarilyUnavailable
        case 500...599:
            return .serverError(message)
        default:
            return .unknownError(statusCode, message)
        }
    }
}

// MARK: - Equatable Conformance

extension APIError {
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        // Authentication Errors
        case (.unauthorized, .unauthorized): return true
        case (.invalidCredentials, .invalidCredentials): return true
        case (.tokenExpired, .tokenExpired): return true
        case (.tokenInvalid, .tokenInvalid): return true
        case (.refreshTokenExpired, .refreshTokenExpired): return true
        case (.authenticationRequired, .authenticationRequired): return true
        case (.forbidden(let lhsMsg), .forbidden(let rhsMsg)): return lhsMsg == rhsMsg
        case (.twoFactorRequired, .twoFactorRequired): return true
        case (.passwordChangeRequired, .passwordChangeRequired): return true
        case (.accountLocked(let lhsMsg), .accountLocked(let rhsMsg)): return lhsMsg == rhsMsg
        case (.loginAttemptsExceeded, .loginAttemptsExceeded): return true
            
        // Validation Errors
        case (.badRequest(let lhsMsg), .badRequest(let rhsMsg)): return lhsMsg == rhsMsg
        case (.validationError(let lhsMsg), .validationError(let rhsMsg)): return lhsMsg == rhsMsg
        case (.missingRequiredField(let lhsField), .missingRequiredField(let rhsField)): return lhsField == rhsField
        case (.invalidFieldFormat(let lhsMsg, let lhsField), .invalidFieldFormat(let rhsMsg, let rhsField)): 
            return lhsMsg == rhsMsg && lhsField == rhsField
        case (.fieldTooLong(let lhsMsg, let lhsField, let lhsMax), .fieldTooLong(let rhsMsg, let rhsField, let rhsMax)): 
            return lhsMsg == rhsMsg && lhsField == rhsField && lhsMax == rhsMax
        case (.fieldTooShort(let lhsMsg, let lhsField, let lhsMin), .fieldTooShort(let rhsMsg, let rhsField, let rhsMin)): 
            return lhsMsg == rhsMsg && lhsField == rhsField && lhsMin == rhsMin
        case (.invalidEmailFormat, .invalidEmailFormat): return true
        case (.invalidPasswordFormat, .invalidPasswordFormat): return true
        case (.passwordTooWeak, .passwordTooWeak): return true
        case (.usernameUnavailable, .usernameUnavailable): return true
        case (.emailAlreadyExists, .emailAlreadyExists): return true
            
        // Resource Errors
        case (.notFound(let lhsMsg), .notFound(let rhsMsg)): return lhsMsg == rhsMsg
        case (.resourceNotFound(let lhsMsg, let lhsType), .resourceNotFound(let rhsMsg, let rhsType)): 
            return lhsMsg == rhsMsg && lhsType == rhsType
        case (.conflict(let lhsMsg), .conflict(let rhsMsg)): return lhsMsg == rhsMsg
        case (.resourceAlreadyExists(let lhsMsg, let lhsType), .resourceAlreadyExists(let rhsMsg, let rhsType)): 
            return lhsMsg == rhsMsg && lhsType == rhsType
        case (.resourceLocked(let lhsMsg), .resourceLocked(let rhsMsg)): return lhsMsg == rhsMsg
        case (.resourceDeleted(let lhsMsg), .resourceDeleted(let rhsMsg)): return lhsMsg == rhsMsg
        case (.resourceUnavailable(let lhsMsg), .resourceUnavailable(let rhsMsg)): return lhsMsg == rhsMsg
            
        // Network Errors
        case (.networkError, .networkError): return true
        case (.noInternetConnection, .noInternetConnection): return true
        case (.timeout, .timeout): return true
        case (.invalidURL, .invalidURL): return true
        case (.invalidResponse, .invalidResponse): return true
        case (.rateLimited(let lhsRetry), .rateLimited(let rhsRetry)): return lhsRetry == rhsRetry
        case (.serviceUnavailable(let lhsMsg), .serviceUnavailable(let rhsMsg)): return lhsMsg == rhsMsg
            
        // Server Errors
        case (.serverError(let lhsMsg), .serverError(let rhsMsg)): return lhsMsg == rhsMsg
        case (.internalServerError, .internalServerError): return true
        case (.badGateway, .badGateway): return true
        case (.serviceTemporarilyUnavailable, .serviceTemporarilyUnavailable): return true
        case (.maintenanceMode(let lhsMsg), .maintenanceMode(let rhsMsg)): return lhsMsg == rhsMsg
        case (.databaseError(let lhsMsg), .databaseError(let rhsMsg)): return lhsMsg == rhsMsg
        case (.thirdPartyServiceError(let lhsMsg, let lhsService), .thirdPartyServiceError(let rhsMsg, let rhsService)): 
            return lhsMsg == rhsMsg && lhsService == rhsService
            
        // Data Processing Errors
        case (.decodingError, .decodingError): return true
        case (.encodingError, .encodingError): return true
        case (.dataCorrupted(let lhsMsg), .dataCorrupted(let rhsMsg)): return lhsMsg == rhsMsg
        case (.unsupportedDataFormat(let lhsFormat), .unsupportedDataFormat(let rhsFormat)): return lhsFormat == rhsFormat
        case (.dataTooLarge(let lhsMsg, let lhsMax), .dataTooLarge(let rhsMsg, let rhsMax)): 
            return lhsMsg == rhsMsg && lhsMax == rhsMax
            
        // Business Logic Errors
        case (.insufficientPermissions(let lhsMsg), .insufficientPermissions(let rhsMsg)): return lhsMsg == rhsMsg
        case (.quotaExceeded(let lhsMsg, let lhsLimit), .quotaExceeded(let rhsMsg, let rhsLimit)): 
            return lhsMsg == rhsMsg && lhsLimit == rhsLimit
        case (.featureNotEnabled(let lhsFeature), .featureNotEnabled(let rhsFeature)): return lhsFeature == rhsFeature
        case (.subscriptionRequired(let lhsMsg), .subscriptionRequired(let rhsMsg)): return lhsMsg == rhsMsg
        case (.subscriptionExpired, .subscriptionExpired): return true
        case (.paymentRequired(let lhsMsg), .paymentRequired(let rhsMsg)): return lhsMsg == rhsMsg
        case (.trialExpired, .trialExpired): return true
            
        // System Errors
        case (.configurationError(let lhsMsg), .configurationError(let rhsMsg)): return lhsMsg == rhsMsg
        case (.systemOverloaded, .systemOverloaded): return true
        case (.diskSpaceFull, .diskSpaceFull): return true
        case (.memoryError, .memoryError): return true
        case (.fileSystemError(let lhsMsg), .fileSystemError(let rhsMsg)): return lhsMsg == rhsMsg
            
        // Generic/Unknown Errors
        case (.unknownError(let lhsCode, let lhsMsg), .unknownError(let rhsCode, let rhsMsg)): 
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        case (.customError(let lhsMsg, let lhsCode), .customError(let rhsMsg, let rhsCode)): 
            return lhsMsg == rhsMsg && lhsCode == rhsCode
            
        default:
            return false
        }
    }
}