import Foundation
import Combine

/**
 * Network Client Service
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles HTTP network communication
 * - OCP: Extensible for new request types and middleware
 * - LSP: URLSession can be substituted with mock for testing
 * - ISP: Focused interface for network operations
 * - DIP: Depends on URLSession abstraction, not concrete implementation
 */

class NetworkClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder.apiDecoder
    }
    
    // MARK: - Public Methods
    
    /**
     * Perform HTTP request with generic response type
     */
    func performRequest<T: Decodable>(
        _ request: URLRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        logRequest(request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                self?.logResponse(response, data: data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                // CRITICAL: Check for errors BEFORE attempting to decode success response
                
                // 1. Check HTTP status code first
                if httpResponse.statusCode >= 400 {
                    throw APIError.fromHTTPResponse(statusCode: httpResponse.statusCode, data: data)
                }
                
                // 2. Skip error response check for now to avoid module dependencies
                
                // 3. Process JSON if needed
                let processedData = self?.processJSONIfNeeded(data) ?? data
                
                // 4. Now safe to return data for success decoding
                return processedData
            }
            .decode(type: responseType, decoder: decoder)
            .mapError { [weak self] error in
                self?.mapError(error) ?? APIError.decodingError
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /**
     * Perform HTTP request without decoding response (for uploads, etc.)
     */
    func performRequest(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), APIError> {
        logRequest(request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                self?.logResponse(response, data: data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if httpResponse.statusCode >= 400 {
                    throw APIError.fromHTTPResponse(statusCode: httpResponse.statusCode, data: data)
                }
                
                return (data, httpResponse)
            }
            .mapError { [weak self] error in
                self?.mapError(error) ?? APIError.networkError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * Log outgoing HTTP request
     */
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("📤 HTTP Request:")
        print("   Method: \(request.httpMethod ?? "GET")")
        print("   URL: \(request.url?.absoluteString ?? "Unknown")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   Headers:")
            for (key, value) in headers {
                // Don't log sensitive headers
                if key.lowercased().contains("authorization") {
                    print("      \(key): [REDACTED]")
                } else {
                    print("      \(key): \(value)")
                }
            }
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyString)")
        }
        #endif
    }
    
    /**
     * Log incoming HTTP response
     */
    private func logResponse(_ response: URLResponse, data: Data) {
        #if DEBUG
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        print("📥 HTTP Response:")
        print("   Status: \(httpResponse.statusCode)")
        print("   URL: \(httpResponse.url?.absoluteString ?? "Unknown")")
        
        if let headers = httpResponse.allHeaderFields as? [String: String], !headers.isEmpty {
            print("   Headers:")
            for (key, value) in headers {
                print("      \(key): \(value)")
            }
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString)")
        }
        #endif
    }
    
    /**
     * Process JSON response data if needed
     */
    private func processJSONIfNeeded(_ data: Data) -> Data {
        // Handle any JSON preprocessing if needed
        // For now, return data as-is
        return data
    }
    
    /**
     * Map various error types to APIError
     */
    private func mapError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let urlError = error as? URLError {
            return mapURLError(urlError)
        }
        
        if error is DecodingError {
            print("❌ Decoding Error Details: \(error)")
            return .decodingError
        }
        
        if error is EncodingError {
            return .encodingError
        }
        
        return .networkError(error)
    }
    
    /**
     * Map URLError to appropriate APIError
     */
    private func mapURLError(_ urlError: URLError) -> APIError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        case .cancelled:
            return .networkError(urlError)
        default:
            return .networkError(urlError)
        }
    }
}

