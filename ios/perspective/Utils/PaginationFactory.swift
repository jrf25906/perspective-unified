import Foundation

/**
 * Pagination Factory
 * 
 * Centralized creation and management of pagination models
 * Prevents scope issues and ensures consistent pagination behavior
 * 
 * SOLID Principles Applied:
 * - SRP: Single responsibility for pagination creation and validation
 * - OCP: Open for extension (new pagination types), closed for modification
 * - LSP: All pagination types are substitutable where their protocols are used
 * - ISP: Segregated interfaces for offset-based vs page-based pagination
 * - DIP: Depends on abstractions (protocols) not concrete implementations
 */

struct PaginationFactory {
    
    // MARK: - Page-Based Pagination Factory
    
    /**
     * Creates page-based pagination metadata with validation
     * Ensures all values are within valid ranges
     */
    static func createPageMetadata<T>(
        page: Int,
        limit: Int,
        total: Int,
        type: T.Type = T.self
    ) -> PagedAPIResponse<T>.PageMetadata {
        // Validate input parameters
        let validPage = max(1, page)
        let validLimit = max(1, limit)
        let validTotal = max(0, total)
        
        // Calculate total pages
        let totalPages = validTotal > 0 ? (validTotal + validLimit - 1) / validLimit : 1
        
        // Ensure page doesn't exceed total pages
        let finalPage = min(validPage, totalPages)
        
        return PagedAPIResponse<T>.PageMetadata(
            page: finalPage,
            limit: validLimit,
            total: validTotal,
            totalPages: totalPages
        )
    }
    
    /**
     * Creates a complete paged API response
     * Provides type-safe pagination with data
     */
    static func createPagedResponse<T: Decodable>(
        data: [T],
        page: Int,
        limit: Int,
        total: Int
    ) -> PagedAPIResponse<T> {
        let metadata = createPageMetadata(page: page, limit: limit, total: total, type: T.self)
        return PagedAPIResponse(data: data, pagination: metadata)
    }
    
    /**
     * Creates pagination metadata from offset-based parameters
     * Converts offset/limit to page-based pagination
     */
    static func createPageMetadataFromOffset<T>(
        offset: Int,
        limit: Int,
        total: Int,
        type: T.Type = T.self
    ) -> PagedAPIResponse<T>.PageMetadata {
        let page = (offset / limit) + 1
        return createPageMetadata(page: page, limit: limit, total: total, type: type)
    }
    
    // MARK: - Offset-Based Pagination Helpers
    
    /**
     * Creates offset-based pagination info
     * Used for APIs that use offset/limit/hasMore pattern
     */
    static func createOffsetPaginationInfo(
        offset: Int,
        limit: Int,
        totalItems: Int? = nil,
        hasMore: Bool? = nil
    ) -> OffsetPaginationInfo {
        let validOffset = max(0, offset)
        let validLimit = max(1, limit)
        
        // Calculate hasMore if not provided
        let calculatedHasMore: Bool
        if let hasMore = hasMore {
            calculatedHasMore = hasMore
        } else if let totalItems = totalItems {
            calculatedHasMore = (validOffset + validLimit) < totalItems
        } else {
            calculatedHasMore = false // Conservative default
        }
        
        return OffsetPaginationInfo(
            offset: validOffset,
            limit: validLimit,
            hasMore: calculatedHasMore
        )
    }
    
    /**
     * Converts page-based pagination to offset-based
     * Useful for APIs that expect offset/limit parameters
     */
    static func convertToOffset(page: Int, limit: Int) -> (offset: Int, limit: Int) {
        let validPage = max(1, page)
        let validLimit = max(1, limit)
        let offset = (validPage - 1) * validLimit
        return (offset: offset, limit: validLimit)
    }
    
    // MARK: - Validation Methods
    
    /**
     * Validates pagination parameters
     * Returns tuple with (isValid, errorMessage)
     */
    static func validatePaginationParameters(
        page: Int,
        limit: Int,
        total: Int
    ) -> (isValid: Bool, errorMessage: String?) {
        if page < 1 {
            return (false, "Page must be greater than 0")
        }
        
        if limit < 1 {
            return (false, "Limit must be greater than 0")
        }
        
        if limit > 1000 {
            return (false, "Limit must not exceed 1000 items")
        }
        
        if total < 0 {
            return (false, "Total must not be negative")
        }
        
        let totalPages = total > 0 ? (total + limit - 1) / limit : 1
        if page > totalPages {
            return (false, "Page \(page) exceeds total pages (\(totalPages))")
        }
        
        return (true, nil)
    }
    
    /**
     * Validates offset-based pagination parameters
     */
    static func validateOffsetParameters(
        offset: Int,
        limit: Int
    ) -> (isValid: Bool, errorMessage: String?) {
        if offset < 0 {
            return (false, "Offset must not be negative")
        }
        
        if limit < 1 {
            return (false, "Limit must be greater than 0")
        }
        
        if limit > 1000 {
            return (false, "Limit must not exceed 1000 items")
        }
        
        return (true, nil)
    }
    
    // MARK: - Pagination Analysis
    
    /**
     * Analyzes pagination performance and provides insights
     */
    static func analyzePagination(
        totalItems: Int,
        itemsPerPage: Int
    ) -> PaginationAnalysis {
        let totalPages = totalItems > 0 ? (totalItems + itemsPerPage - 1) / itemsPerPage : 0
        
        let memoryEfficiency: PaginationAnalysis.Efficiency
        if itemsPerPage <= 10 {
            memoryEfficiency = .high
        } else if itemsPerPage <= 50 {
            memoryEfficiency = .medium
        } else {
            memoryEfficiency = .low
        }
        
        let networkEfficiency: PaginationAnalysis.Efficiency
        if totalPages <= 10 {
            networkEfficiency = .high
        } else if totalPages <= 100 {
            networkEfficiency = .medium
        } else {
            networkEfficiency = .low
        }
        
        return PaginationAnalysis(
            totalPages: totalPages,
            memoryEfficiency: memoryEfficiency,
            networkEfficiency: networkEfficiency,
            recommendedPageSize: calculateOptimalPageSize(totalItems: totalItems)
        )
    }
    
    /**
     * Calculates optimal page size based on total items
     */
    private static func calculateOptimalPageSize(totalItems: Int) -> Int {
        switch totalItems {
        case 0...100:
            return min(totalItems, 20)
        case 101...1000:
            return 25
        case 1001...10000:
            return 50
        default:
            return 100
        }
    }
}

// MARK: - Supporting Types

/**
 * Offset-based pagination information
 * Implements OffsetBasedPagination protocol
 */
struct OffsetPaginationInfo: OffsetBasedPagination {
    let offset: Int
    let limit: Int
    let hasMore: Bool
}

/**
 * Pagination analysis result
 * Provides insights into pagination performance
 */
struct PaginationAnalysis {
    let totalPages: Int
    let memoryEfficiency: Efficiency
    let networkEfficiency: Efficiency
    let recommendedPageSize: Int
    
    enum Efficiency {
        case high, medium, low
        
        var description: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
    }
    
    /// Overall efficiency score (0.0 to 1.0)
    var overallEfficiency: Double {
        let memoryScore = memoryEfficiency.score
        let networkScore = networkEfficiency.score
        return (memoryScore + networkScore) / 2.0
    }
}

private extension PaginationAnalysis.Efficiency {
    var score: Double {
        switch self {
        case .high: return 1.0
        case .medium: return 0.6
        case .low: return 0.3
        }
    }
} 