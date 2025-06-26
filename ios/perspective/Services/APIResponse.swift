import Foundation
import Combine

// MARK: - API Response Protocol

/// Protocol for handling API responses with proper error detection
protocol APIResponseHandler {
    associatedtype SuccessType: Decodable
    static func decode(from data: Data, statusCode: Int) throws -> Result<SuccessType, APIError>
}

// MARK: - Standard API Response

/// Generic response handler for standard API responses
struct StandardAPIResponse<T: Decodable>: APIResponseHandler {
    typealias SuccessType = T
    
    static func decode(from data: Data, statusCode: Int) throws -> Result<T, APIError> {
        // First check for error response structure
        if let errorResponse = APIResponseMapper.decodeErrorResponse(from: data) {
            return .failure(APIResponseMapper.mapErrorResponse(errorResponse, statusCode: statusCode))
        }
        
        // Then try to decode success response
        do {
            let successResponse = try JSONDecoder.apiDecoder.decode(T.self, from: data)
            return .success(successResponse)
        } catch {
            // If decoding fails, check if it's actually an error response we couldn't decode
            if statusCode >= 400 {
                let message = APIResponseMapper.extractErrorMessage(from: data)
                return .failure(APIError.unknownError(statusCode, message))
            }
            // Otherwise, it's a genuine decoding error
            throw error
        }
    }
    
}

// MARK: - Page-Based API Response

/// Response wrapper for page-based paginated API responses
/// Uses page/limit/total pagination model (different from offset-based pagination)
struct PagedAPIResponse<T: Decodable>: Decodable {
    let data: [T]
    let pagination: PageMetadata
    
    struct PageMetadata: Decodable, PageBasedPagination {
        let page: Int
        let limit: Int
        let total: Int
        let totalPages: Int
        
        enum CodingKeys: String, CodingKey {
            case page
            case limit
            case total
            case totalPages
        }
    }
}

// MARK: - Empty Response

/// Response handler for endpoints that return no content
struct EmptyAPIResponse: APIResponseHandler {
    typealias SuccessType = EmptyResponse
    
    struct EmptyResponse: Decodable {}
    
    static func decode(from data: Data, statusCode: Int) throws -> Result<EmptyResponse, APIError> {
        // Check for error response even if we expect empty
        if let errorResponse = try? JSONDecoder.apiDecoder.decode(ErrorResponse.self, from: data) {
            return .failure(APIResponseMapper.mapErrorResponse(errorResponse, statusCode: statusCode))
        }
        
        // For 204 No Content or empty 200 responses
        if statusCode == 204 || data.isEmpty {
            return .success(EmptyResponse())
        }
        
        // Try to decode as empty response
        do {
            let response = try JSONDecoder.apiDecoder.decode(EmptyResponse.self, from: data)
            return .success(response)
        } catch {
            if statusCode >= 400 {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                return .failure(APIError.unknownError(statusCode, message))
            }
            throw error
        }
    }
}

// MARK: - Response Type Aliases

typealias UserAPIResponse = StandardAPIResponse<User>
typealias AuthAPIResponse = StandardAPIResponse<AuthResponse>
typealias ChallengeAPIResponse = StandardAPIResponse<Challenge>
typealias ChallengeListAPIResponse = StandardAPIResponse<[Challenge]>
typealias EchoScoreAPIResponse = StandardAPIResponse<EchoScore>

// MARK: - Pagination Response Type Aliases

typealias PagedUserResponse = PagedAPIResponse<User>
typealias PagedChallengeResponse = PagedAPIResponse<Challenge>
typealias PagedActivityResponse = PagedAPIResponse<ActivityEvent>

// MARK: - Response Extensions

extension Result where Success: Decodable, Failure == APIError {
    /// Maps the success value to a different type
    func mapSuccess<T>(_ transform: (Success) throws -> T) -> Result<T, APIError> {
        switch self {
        case .success(let value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(.decodingError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Extracts the success value or nil
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Extracts the error or nil
    var error: APIError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - Network Client Extension

extension NetworkClient {
    /// Performs a request with proper response handling
    func performRequestWithResponseHandler<T: APIResponseHandler>(
        _ request: URLRequest,
        responseHandler: T.Type
    ) -> AnyPublisher<T.SuccessType, APIError> {
        performRequest(request)
            .tryMap { (data, httpResponse) in
                let result = try T.decode(from: data, statusCode: httpResponse.statusCode)
                switch result {
                case .success(let value):
                    return value
                case .failure(let error):
                    throw error
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Pagination Extensions

extension PagedAPIResponse {
    /// Convenience computed properties for pagination metadata
    var currentPage: Int { pagination.page }
    var itemsPerPage: Int { pagination.limit }
    var totalItems: Int { pagination.total }
    var totalPages: Int { pagination.totalPages }
    
    /// Check if there are more pages available
    var hasNextPage: Bool { pagination.page < pagination.totalPages }
    var hasPreviousPage: Bool { pagination.page > 1 }
    
    /// Calculate next and previous page numbers
    var nextPage: Int? { hasNextPage ? pagination.page + 1 : nil }
    var previousPage: Int? { hasPreviousPage ? pagination.page - 1 : nil }
    
    /// Get page range for display (e.g., "1-10 of 50")
    var displayRange: String {
        let startItem = (pagination.page - 1) * pagination.limit + 1
        let endItem = min(pagination.page * pagination.limit, pagination.total)
        return "\(startItem)-\(endItem) of \(pagination.total)"
    }
    
    /// Check if this response is empty
    var isEmpty: Bool { data.isEmpty }
    
    /// Check if this is the first page
    var isFirstPage: Bool { pagination.page == 1 }
    
    /// Check if this is the last page
    var isLastPage: Bool { pagination.page == pagination.totalPages }
    
    /// Get items for current page only (useful for display)
    var currentPageItems: [T] { data }
    
    /// Calculate the range of item indices for the current page
    var itemIndexRange: Range<Int> {
        let startIndex = (pagination.page - 1) * pagination.limit
        let endIndex = min(startIndex + data.count, pagination.total)
        return startIndex..<endIndex
    }
}

extension PagedAPIResponse.PageMetadata {
    /// Convenience method to create pagination metadata
    static func create(page: Int, limit: Int, total: Int) -> Self {
        let totalPages = total > 0 ? (total + limit - 1) / limit : 0
        return Self(page: page, limit: limit, total: total, totalPages: totalPages)
    }
    
    /// Check if the current page is valid
    var isValidPage: Bool {
        return page >= 1 && page <= totalPages
    }
    
    /// Calculate page offset for offset-based APIs
    var offsetEquivalent: Int {
        return (page - 1) * limit
    }
    
    /// Create metadata for the next page
    var nextPageMetadata: Self? {
        guard page < totalPages else { return nil }
        return Self(page: page + 1, limit: limit, total: total, totalPages: totalPages)
    }
    
    /// Create metadata for the previous page
    var previousPageMetadata: Self? {
        guard page > 1 else { return nil }
        return Self(page: page - 1, limit: limit, total: total, totalPages: totalPages)
    }
}