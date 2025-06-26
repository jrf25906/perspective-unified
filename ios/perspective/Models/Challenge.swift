import Foundation

/**
 * Challenge Models
 * 
 * Core data structures for the challenge system
 * Supports various challenge types with flexible content structure
 * 
 * SOLID Principles Applied:
 * - SRP: Each model has single responsibility for its data
 * - OCP: Extensible for new challenge types and properties
 * - LSP: All challenge types are interchangeable where Challenge is used
 * - ISP: Focused interfaces for each challenge aspect
 * - DIP: Depends on Codable and Foundation abstractions
 */

// MARK: - Challenge Model

public struct Challenge: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String
    public let type: ChallengeType
    public let content: ChallengeContent
    public let difficulty: ChallengeDifficulty
    public let xpReward: Int
    public let timeLimit: Int? // in seconds
    public let isDaily: Bool
    public let availableAt: Date?
    public let expiresAt: Date?
    public let createdAt: Date
    public let updatedAt: Date?
    
    public enum CodingKeys: String, CodingKey {
        case id, title, description, type, content, difficulty
        case xpReward, timeLimit, isDaily, availableAt, expiresAt
        case createdAt, updatedAt
    }
}

// MARK: - Challenge Type

public enum ChallengeType: String, Codable, CaseIterable {
    case multipleChoice = "multiple_choice"
    case trueFalse = "true_false"
    case shortAnswer = "short_answer"
    case essay = "essay"
    case matching = "matching"
    case ranking = "ranking"
    case scenario = "scenario"
    
    public var displayName: String {
        switch self {
        case .multipleChoice:
            return "Multiple Choice"
        case .trueFalse:
            return "True/False"
        case .shortAnswer:
            return "Short Answer"
        case .essay:
            return "Essay"
        case .matching:
            return "Matching"
        case .ranking:
            return "Ranking"
        case .scenario:
            return "Scenario"
        }
    }
    
    public var description: String {
        switch self {
        case .multipleChoice:
            return "Select the best answer from multiple options"
        case .trueFalse:
            return "Determine if the statement is true or false"
        case .shortAnswer:
            return "Provide a brief answer to the question"
        case .essay:
            return "Write a detailed response"
        case .matching:
            return "Match items from two lists"
        case .ranking:
            return "Rank items in order of preference or importance"
        case .scenario:
            return "Analyze a situation and provide your perspective"
        }
    }
}

// MARK: - Challenge Difficulty

public enum ChallengeDifficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var xpMultiplier: Double {
        switch self {
        case .beginner:
            return 1.0
        case .intermediate:
            return 1.25
        case .advanced:
            return 1.5
        case .expert:
            return 2.0
        }
    }
    
    public var color: String {
        switch self {
        case .beginner:
            return "green"
        case .intermediate:
            return "blue"
        case .advanced:
            return "orange"
        case .expert:
            return "red"
        }
    }
}

// MARK: - Challenge Content

public struct ChallengeContent: Codable {
    public let question: String
    public let context: String?
    public let options: [ChallengeOption]?
    public let correctAnswer: AnyCodable?
    public let explanation: String?
    public let hints: [String]?
    public let sources: [ChallengeSource]?
    public let media: [ChallengeMedia]?
    
    public enum CodingKeys: String, CodingKey {
        case question, context, options, correctAnswer, explanation
        case hints, sources, media
    }
}

// MARK: - Challenge Option

public struct ChallengeOption: Codable, Identifiable {
    public let id: String
    public let text: String
    public let isCorrect: Bool?
    public let explanation: String?
    
    public enum CodingKeys: String, CodingKey {
        case id, text, isCorrect, explanation
    }
}

// MARK: - Challenge Source

public struct ChallengeSource: Codable {
    public let title: String
    public let url: String?
    public let author: String?
    public let publishedAt: Date?
    public let credibilityScore: Double?
    
    public enum CodingKeys: String, CodingKey {
        case title, url, author, publishedAt, credibilityScore
    }
}

// MARK: - Challenge Media

public struct ChallengeMedia: Codable {
    public let type: MediaType
    public let url: String
    public let caption: String?
    public let altText: String?
    
    public enum MediaType: String, Codable {
        case image = "image"
        case video = "video"
        case audio = "audio"
        case document = "document"
    }
    
    public enum CodingKeys: String, CodingKey {
        case type, url, caption, altText
    }
}

// MARK: - Challenge Submission

public struct ChallengeSubmission: Codable {
    public let answer: AnyCodable
    public let timeSpentSeconds: Int
    public let confidence: Double?
    public let reasoning: String?
    
    public enum CodingKeys: String, CodingKey {
        case answer, timeSpentSeconds, confidence, reasoning
    }
}

// MARK: - Challenge Result

public struct ChallengeResult: Codable {
    public let isCorrect: Bool
    public let feedback: String
    public let xpEarned: Int
    public let streakInfo: StreakInfo
    public let detailedFeedback: DetailedFeedback?
    public let nextChallengeAvailable: Date?
    
    public enum CodingKeys: String, CodingKey {
        case isCorrect, feedback, xpEarned, streakInfo
        case detailedFeedback, nextChallengeAvailable
    }
}

// MARK: - Detailed Feedback

public struct DetailedFeedback: Codable {
    public let explanation: String
    public let correctAnswer: AnyCodable
    public let userAnswer: AnyCodable
    public let biasesDetected: [String]?
    public let improvementSuggestions: [String]?
    public let relatedSources: [ChallengeSource]?
    
    public enum CodingKeys: String, CodingKey {
        case explanation, correctAnswer, userAnswer
        case biasesDetected, improvementSuggestions, relatedSources
    }
}

// MARK: - Streak Information

public struct StreakInfo: Codable {
    public let current: Int
    public let longest: Int
    public let isActive: Bool
    public let lastActivityDate: Date?
    
    public enum CodingKeys: String, CodingKey {
        case current, longest, isActive, lastActivityDate
    }
}

// MARK: - Challenge Statistics

public struct ChallengeStats: Codable {
    public let totalChallengesCompleted: Int
    public let totalCorrect: Int
    public let averageAccuracy: Double
    public let averageTimeSpent: Double
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalXpEarned: Int
    public let difficultyCounts: [ChallengeDifficulty: Int]
    public let typeCounts: [ChallengeType: Int]
    public let recentActivity: [RecentActivity]
    
    public enum CodingKeys: String, CodingKey {
        case totalChallengesCompleted, totalCorrect, averageAccuracy
        case averageTimeSpent, currentStreak, longestStreak, totalXpEarned
        case difficultyCounts, typeCounts, recentActivity
    }
}

// MARK: - Recent Activity

public struct RecentActivity: Codable, Identifiable {
    public let id: Int
    public let type: ActivityType
    public let title: String
    public let description: String
    public let xpEarned: Int?
    public let timestamp: Date
    public let metadata: [String: AnyCodable]?
    
    public enum ActivityType: String, Codable {
        case challengeCompleted = "challenge_completed"
        case streakMilestone = "streak_milestone"
        case xpEarned = "xp_earned"
        case achievementUnlocked = "achievement_unlocked"
    }
    
    public enum CodingKeys: String, CodingKey {
        case id, type, title, description, xpEarned, timestamp, metadata
    }
}

// MARK: - Leaderboard Entry

public struct LeaderboardEntry: Codable, Identifiable {
    public let id: Int
    public let userId: Int
    public let username: String
    public let avatarUrl: String?
    public let rank: Int
    public let score: Int
    public let completedChallenges: Int
    public let accuracy: Double
    public let streak: Int
    public let isCurrentUser: Bool?
    
    public enum CodingKeys: String, CodingKey {
        case id, userId, username, avatarUrl, rank, score
        case completedChallenges, accuracy, streak, isCurrentUser
    }
}