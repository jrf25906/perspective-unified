import Foundation

/**
 * Response Models Factory
 * 
 * Centralized creation and validation of API response models
 * Ensures consistency and prevents duplication across the application
 * 
 * SOLID Principles Applied:
 * - SRP: Single responsibility for response model creation and validation
 * - OCP: Open for extension (new response types), closed for modification
 * - LSP: All response types conform to common protocols where applicable
 * - ISP: Segregated interfaces for different response categories
 * - DIP: Depends on abstractions (Codable, protocols) not concretions
 */

struct ResponseModelsFactory {
    
    // MARK: - Avatar Response Models
    
    /**
     * Creates a standardized avatar upload response
     * Used across all avatar-related operations for consistency
     */
    static func createAvatarUploadResponse(
        success: Bool = true,
        avatarUrl: String,
        message: String = "Avatar uploaded successfully"
    ) -> AvatarUploadResponse {
        return AvatarUploadResponse(
            success: success,
            avatarUrl: avatarUrl,
            message: message
        )
    }
    
    /**
     * Creates a standardized avatar URL response
     * Handles both authenticated and public avatar retrievals
     */
    static func createAvatarUrlResponse(
        userId: Int,
        avatarUrl: String?,
        hasAvatar: Bool? = nil
    ) -> AvatarUrlResponse {
        return AvatarUrlResponse(
            userId: userId,
            avatarUrl: avatarUrl,
            hasAvatar: hasAvatar ?? (avatarUrl != nil)
        )
    }
    
    /**
     * Creates a standardized avatar deletion response
     * Ensures consistent feedback for deletion operations
     */
    static func createAvatarDeletionResponse(
        success: Bool = true,
        message: String = "Avatar deleted successfully"
    ) -> AvatarDeletionResponse {
        return AvatarDeletionResponse(
            success: success,
            message: message
        )
    }
    
    // MARK: - Activity Response Models
    
    /**
     * Creates a standardized recent activities response wrapper
     * Encapsulates activity data with metadata
     */
    static func createRecentActivitiesResponse(
        activities: [ActivityEvent],
        totalCount: Int? = nil
    ) -> RecentActivitiesResponse {
        return RecentActivitiesResponse(
            success: true,
            data: RecentActivitiesData(
                activities: activities,
                totalCount: totalCount ?? activities.count
            )
        )
    }
    
    /**
     * Creates a standardized activity summary response
     * Provides comprehensive activity analytics
     */
    static func createActivitySummaryResponse(
        totalActivities: Int,
        recentActivities: [ActivityEvent],
        activitiesByType: [String: Int] = [:],
        activitiesByCategory: [String: Int] = [:],
        lastActivityDate: Date? = nil
    ) -> ActivitySummaryResponse {
        return ActivitySummaryResponse(
            success: true,
            data: ActivitySummary(
                totalActivities: totalActivities,
                recentActivities: recentActivities,
                activitiesByType: activitiesByType,
                activitiesByCategory: activitiesByCategory,
                lastActivityDate: lastActivityDate
            )
        )
    }
    
    /**
     * Creates a standardized public activity feed response
     * Handles pagination and public visibility filtering
     */
    static func createPublicActivityFeedResponse(
        activities: [ActivityEvent],
        limit: Int,
        offset: Int,
        hasMore: Bool? = nil
    ) -> PublicActivityFeedResponse {
        return PublicActivityFeedResponse(
            success: true,
            data: PublicActivityFeedData(
                activities: activities,
                limit: limit,
                offset: offset,
                hasMore: hasMore ?? (activities.count == limit)
            )
        )
    }
    
    // MARK: - Activity Event Factory
    
    /**
     * Creates a standardized activity event
     * Ensures consistent activity tracking across the app
     */
    static func createActivityEvent(
        id: Int? = nil,
        userId: Int,
        type: String,
        title: String,
        description: String,
        metadata: [String: AnyCodable]? = nil,
        xpEarned: Int? = nil,
        timestamp: Date = Date(),
        category: String = "general",
        visibility: String = "public"
    ) -> ActivityEvent {
        return ActivityEvent(
            id: id,
            userId: userId,
            type: type,
            title: title,
            description: description,
            metadata: metadata,
            xpEarned: xpEarned,
            timestamp: timestamp,
            category: category,
            visibility: visibility
        )
    }
    
    // MARK: - Validation Methods
    
    /**
     * Validates that a response model has required fields
     * Used for testing and debugging consistency
     */
    static func validateResponseModel<T: Codable>(_ model: T) -> Bool {
        do {
            let data = try JSONEncoder.apiEncoder.encode(model)
            _ = try JSONDecoder.apiDecoder.decode(T.self, from: data)
            return true
        } catch {
            print("❌ Response model validation failed: \(error)")
            return false
        }
    }
    
    /**
     * Creates mock response models for testing
     * Ensures consistent test data across the application
     */
    static func createMockResponse<T: Codable>(of type: T.Type) -> T? {
        // This method can be extended with specific mock implementations
        // for each response type as needed
        return nil
    }
}

// MARK: - Response Model Extensions

extension ResponseModelsFactory {
    
    /**
     * Creates a generic success response using the centralized SuccessResponse type
     * Promotes reuse of the generic response structure from APIModels
     */
    static func createGenericSuccessResponse<T: Codable>(
        data: T,
        message: String? = nil,
        timestamp: Date = Date()
    ) -> SuccessResponse<T> {
        return SuccessResponse<T>(
            data: data,
            message: message,
            timestamp: timestamp
        )
    }
}

// MARK: - Response Model Protocols

/**
 * Protocol for responses that include success status
 * Enables consistent success/failure handling
 */
protocol SuccessStatusResponse {
    var success: Bool { get }
}

/**
 * Protocol for offset-based pagination metadata
 * Used for responses that use offset/limit/hasMore model (e.g., infinite scroll)
 */
protocol OffsetBasedPagination {
    var limit: Int { get }
    var offset: Int { get }
    var hasMore: Bool { get }
}

/**
 * Protocol for page-based pagination metadata  
 * Used for responses that use page/limit/total/totalPages model (e.g., traditional pagination)
 */
protocol PageBasedPagination {
    var page: Int { get }
    var limit: Int { get }
    var total: Int { get }
    var totalPages: Int { get }
}

/**
 * Legacy alias for offset-based pagination
 * Maintains backward compatibility while providing clearer naming
 */
typealias PaginatedResponse = OffsetBasedPagination

// MARK: - Protocol Conformances

extension AvatarUploadResponse: SuccessStatusResponse {}
extension AvatarDeletionResponse: SuccessStatusResponse {}
extension RecentActivitiesResponse: SuccessStatusResponse {}
extension ActivitySummaryResponse: SuccessStatusResponse {}
extension PublicActivityFeedResponse: SuccessStatusResponse {}

extension PublicActivityFeedData: OffsetBasedPagination {}

// MARK: - Pagination Extensions

extension OffsetBasedPagination {
    /// Calculate the current page number based on offset and limit
    var currentPage: Int {
        return (offset / limit) + 1
    }
    
    /// Calculate the starting item number for display
    var startingItem: Int {
        return offset + 1
    }
    
    /// Calculate the ending item number for display
    var endingItem: Int {
        return offset + limit
    }
    
    /// Get display range for offset-based pagination (e.g., "11-20, more available")
    var displayInfo: String {
        let start = startingItem
        let end = endingItem
        let moreText = hasMore ? ", more available" : ""
        return "\(start)-\(end)\(moreText)"
    }
    
    /// Calculate the next offset for pagination
    var nextOffset: Int? {
        return hasMore ? offset + limit : nil
    }
    
    /// Calculate the previous offset for pagination
    var previousOffset: Int? {
        return offset >= limit ? offset - limit : nil
    }
} 