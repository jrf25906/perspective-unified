import Foundation

// MARK: - Error Response Model

/// Standard error response structure from the API
public struct ErrorResponse: Codable {
    public let error: ErrorDetail
    
    public struct ErrorDetail: Codable {
        public let message: String
        public let code: String?
        public let details: [String: String]?
        
        public init(message: String, code: String? = nil, details: [String: String]? = nil) {
            self.message = message
            self.code = code
            self.details = details
        }
    }
    
    public init(error: ErrorDetail) {
        self.error = error
    }
}

// MARK: - Success Response Models

/// Standard success response wrapper
public struct SuccessResponse<T: Codable>: Codable {
    public let data: T
    public let message: String?
    public let timestamp: Date?
    
    public init(data: T, message: String? = nil, timestamp: Date? = nil) {
        self.data = data
        self.message = message
        self.timestamp = timestamp
    }
}

// MARK: - JSON Processing Utilities

/// Utilities for JSON processing and response handling
public enum JSONProcessingUtilities {
    
    /// Cleans and validates JSON data
    /// - Parameter data: Raw JSON data
    /// - Returns: Cleaned JSON data
    public static func cleanJSONData(_ data: Data) -> Data {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return data
        }
        
        // Remove any potential BOM or whitespace
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedString.data(using: .utf8) ?? data
    }
    
    /// Validates that data contains valid JSON
    /// - Parameter data: Data to validate
    /// - Returns: True if valid JSON
    public static func isValidJSON(_ data: Data) -> Bool {
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }
    
    /// Extracts error message from data
    /// - Parameter data: Response data
    /// - Returns: Human-readable error message
    public static func extractErrorMessage(from data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? "Unknown error occurred"
    }
}

// MARK: - JSONDecoder Extension

public extension JSONDecoder {
    /// Shared JSON decoder with API-specific configuration
    static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        // Configure date decoding strategy
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try different date formats
            let formatters = [
                formatter, // ISO 8601 with milliseconds
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone(secondsFromGMT: 0)
                    return f
                }(),
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone(secondsFromGMT: 0)
                    return f
                }()
            ]
            
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
        
        // Configure key decoding strategy for snake_case
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
}

// MARK: - JSON Encoder Extension

extension JSONEncoder {
    public static let apiEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}