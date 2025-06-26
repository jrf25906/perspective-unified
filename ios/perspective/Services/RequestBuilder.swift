import Foundation

/**
 * Request Builder Service
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles HTTP request construction
 * - OCP: Extensible for new request types and formats
 * - LSP: All request types implement common URLRequest interface
 * - ISP: Focused interface for request building operations
 * - DIP: Depends on Foundation URL/URLRequest abstractions
 */

class RequestBuilder {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let jsonEncoder: JSONEncoder
    private let defaultHeaders: [String: String]
    
    // MARK: - Initialization
    
    init(baseURL: String) {
        // Ensure base URL doesn't end with a slash
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Configure JSON encoder
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        
        self.defaultHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "User-Agent": "PerspectiveApp-iOS/1.0"
        ]
    }
    
    // MARK: - Public Methods
    
    /**
     * Build standard HTTP request with JSON body
     */
    func buildRequest<T: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil,
        headers: [String: String] = [:],
        queryParameters: [String: String]? = nil
    ) throws -> URLRequest {
        let request = try buildBaseRequest(
            endpoint: endpoint,
            method: method,
            headers: headers,
            queryParameters: queryParameters
        )
        
        var mutableRequest = request
        
        // Add body if present
        if let body = body {
            do {
                mutableRequest.httpBody = try jsonEncoder.encode(body)
                
                // Log request for debugging
                #if DEBUG
                if let requestString = String(data: mutableRequest.httpBody!, encoding: .utf8) {
                    print("📤 Request Body: \(requestString)")
                }
                #endif
            } catch {
                print("❌ Encoding Error: \(error)")
                throw RequestBuilderError.encodingError(error)
            }
        }
        
        return mutableRequest
    }
    
    /**
     * Build HTTP request without body (for GET, DELETE, etc.)
     */
    func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        queryParameters: [String: String]? = nil
    ) throws -> URLRequest {
        return try buildBaseRequest(
            endpoint: endpoint,
            method: method,
            headers: headers,
            queryParameters: queryParameters
        )
    }
    
    /**
     * Build multipart form data request for file uploads
     */
    func buildMultipartRequest(
        endpoint: String,
        method: HTTPMethod,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String,
        additionalFields: [String: String] = [:],
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw RequestBuilderError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Generate boundary for multipart data
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Set multipart content type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("PerspectiveApp-iOS/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add custom headers (except Content-Type which we set above)
        if let headers = headers {
            for (key, value) in headers {
                if key.lowercased() != "content-type" {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        // Build multipart body
        let body = try buildMultipartBody(
            boundary: boundary,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            fieldName: fieldName,
            additionalFields: additionalFields
        )
        
        request.httpBody = body
        
        return request
    }
    
    /**
     * Build URL with query parameters
     */
    func buildURL(endpoint: String, queryParameters: [String: String] = [:]) throws -> URL {
        guard let baseUrl = URL(string: baseURL + endpoint) else {
            throw RequestBuilderError.invalidURL
        }
        
        if queryParameters.isEmpty {
            return baseUrl
        }
        
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            throw RequestBuilderError.invalidURL
        }
        
        components.queryItems = queryParameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let finalUrl = components.url else {
            throw RequestBuilderError.invalidURL
        }
        
        return finalUrl
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * Build multipart form data body
     */
    private func buildMultipartBody(
        boundary: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String,
        additionalFields: [String: String]
    ) throws -> Data {
        var body = Data()
        
        // Add text fields
        for (key, value) in additionalFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func buildBaseRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        queryParameters: [String: String]?
    ) throws -> URLRequest {
        // Ensure endpoint starts with a slash
        let normalizedEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        let urlString = baseURL + normalizedEndpoint
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw RequestBuilderError.invalidURL
        }
        
        // Add query parameters
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw RequestBuilderError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Locale.current.identifier, forHTTPHeaderField: "Accept-Language")
        
        // App version header
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            request.setValue("iOS/\(appVersion) (\(buildNumber))", forHTTPHeaderField: "X-App-Version")
        }
        
        // Add custom headers (these override defaults if keys match)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Log request details in debug mode
        #if DEBUG
        print("🌐 Request: \(method.rawValue) \(url.absoluteString)")
        if !headers.isEmpty {
            print("📋 Custom Headers: \(headers)")
        }
        #endif
        
        return request
    }
}

// MARK: - URL Construction Helpers

extension RequestBuilder {
    /// Builds a URL with path parameters replaced
    /// Example: "/users/:id" with ["id": "123"] becomes "/users/123"
    func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        pathParameters: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        var processedEndpoint = endpoint
        
        // Replace path parameters
        if let pathParameters = pathParameters {
            for (key, value) in pathParameters {
                processedEndpoint = processedEndpoint.replacingOccurrences(
                    of: ":\(key)",
                    with: value
                )
            }
        }
        
        return try buildRequest(
            endpoint: processedEndpoint,
            method: method,
            headers: headers,
            queryParameters: queryParameters
        )
    }
}

// MARK: - RequestBuilder Errors

enum RequestBuilderError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case invalidMultipartData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .invalidMultipartData:
            return "Invalid multipart data"
        }
    }
}

// MARK: - JSONEncoder Extension
// Note: apiEncoder is centrally defined in APIModels.swift