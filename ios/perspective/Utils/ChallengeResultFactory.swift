import Foundation

/**
 * ChallengeResult Factory
 * 
 * Centralized creation of ChallengeResult objects with proper parameter management
 * Ensures consistency across online/offline modes and prevents missing parameter errors
 * 
 * SOLID Principles Applied:
 * - SRP: Single responsibility for ChallengeResult creation
 * - OCP: Open for extension (new result types), closed for modification
 * - DIP: Depends on Foundation abstractions, not concrete implementations
 */

struct ChallengeResultFactory {
    
    // MARK: - Result Creation Methods
    
    /**
     * Creates an offline submission result with proper default values
     * Used when user submits a challenge while offline
     */
    static func createOfflineSubmissionResult(
        feedback: String = "Response saved for sync when online",
        nextChallengeAvailable: Date? = nil
    ) -> ChallengeResult {
        let nextAvailable = nextChallengeAvailable ?? Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        return ChallengeResult(
            isCorrect: false, // Default to false for offline submissions
            feedback: feedback,
            xpEarned: 0, // No XP earned until online verification
            streakInfo: StreakInfo(
                current: 0,
                longest: 0,
                isActive: false,
                lastActivityDate: Date()
            ),
            detailedFeedback: nil, // No detailed feedback in offline mode
            nextChallengeAvailable: nextAvailable
        )
    }
    
    /**
     * Creates an optimistic result for queued offline submissions
     * Used when the submission is queued for later processing
     */
    static func createOptimisticResult(
        feedback: String = "Your answer has been saved and will be submitted when you're back online."
    ) -> ChallengeResult {
        return createOfflineSubmissionResult(feedback: feedback)
    }
    
    /**
     * Creates a result for failed network requests with retry information
     * Used when network requests fail but we want to provide user feedback
     */
    static func createNetworkFailureResult(
        error: APIError,
        retryAvailable: Date? = nil
    ) -> ChallengeResult {
        let retryDate = retryAvailable ?? Calendar.current.date(byAdding: .minute, value: 5, to: Date())
        let feedback: String
        
        switch error {
        case .networkError:
            feedback = "Network connection failed. Your answer has been saved for retry."
        case .serverError:
            feedback = "Server is temporarily unavailable. Your answer has been saved."
        case .timeout:
            feedback = "Request timed out. Your answer has been saved for retry."
        default:
            feedback = "Something went wrong. Your answer has been saved."
        }
        
        return ChallengeResult(
            isCorrect: false,
            feedback: feedback,
            xpEarned: 0,
            streakInfo: StreakInfo(
                current: 0,
                longest: 0,
                isActive: false,
                lastActivityDate: Date()
            ),
            detailedFeedback: nil,
            nextChallengeAvailable: retryDate
        )
    }
    
    /**
     * Creates a placeholder result for loading states
     * Used when showing loading indicators with partial information
     */
    static func createLoadingPlaceholder(
        feedback: String = "Submitting your answer..."
    ) -> ChallengeResult {
        return ChallengeResult(
            isCorrect: false,
            feedback: feedback,
            xpEarned: 0,
            streakInfo: StreakInfo(
                current: 0,
                longest: 0,
                isActive: false,
                lastActivityDate: nil
            ),
            detailedFeedback: nil,
            nextChallengeAvailable: nil
        )
    }
    
    // MARK: - Validation Methods
    
    /**
     * Validates that a ChallengeResult has all required parameters
     * Used for testing and debugging to ensure compliance
     */
    static func validateResult(_ result: ChallengeResult) -> Bool {
        // All properties are required except optionals
        // This method can be extended for more complex validation
        return !result.feedback.isEmpty
    }
    
    /**
     * Creates a mock result for testing purposes
     * Used in unit tests and UI previews
     */
    static func createMockResult(
        isCorrect: Bool = true,
        feedback: String = "Great job!",
        xpEarned: Int = 10
    ) -> ChallengeResult {
        return ChallengeResult(
            isCorrect: isCorrect,
            feedback: feedback,
            xpEarned: xpEarned,
            streakInfo: StreakInfo(
                current: 5,
                longest: 10,
                isActive: true,
                lastActivityDate: Date()
            ),
            detailedFeedback: DetailedFeedback(
                explanation: "Mock explanation for testing",
                correctAnswer: AnyCodable("Mock Answer"),
                userAnswer: AnyCodable("User Answer"),
                biasesDetected: ["Confirmation Bias"],
                improvementSuggestions: ["Consider alternative perspectives"],
                relatedSources: []
            ),
            nextChallengeAvailable: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        )
    }
}

// MARK: - Extensions for Convenience

extension ChallengeResult {
    
    /**
     * Computed property to check if this is an offline result
     * Useful for UI state management
     */
    var isOfflineResult: Bool {
        return xpEarned == 0 && 
               !isCorrect && 
               detailedFeedback == nil &&
               (feedback.contains("offline") || feedback.contains("saved"))
    }
    
    /**
     * Computed property to check if retry is available
     * Based on nextChallengeAvailable timestamp
     */
    var canRetry: Bool {
        guard let nextAvailable = nextChallengeAvailable else { return true }
        return Date() >= nextAvailable
    }
} 