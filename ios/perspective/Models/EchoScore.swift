import Foundation

// MARK: - Echo Score

public struct EchoScore: Codable {
    public let currentScore: Double
    public let scoreBreakdown: ScoreBreakdown
    public let insights: [ScoreInsight]
    public let trend: ScoreTrend
    public let lastUpdated: Date
    
    public enum CodingKeys: String, CodingKey {
        case currentScore, scoreBreakdown, insights, trend, lastUpdated
    }
}

// MARK: - Echo Score History

public struct EchoScoreHistory: Codable, Identifiable {
    public let id: Int
    public let score: Double
    public let scoreDate: Date
    public let components: ScoreComponents
    public let activitiesCount: Int
    public let challengesCompleted: Int
    
    public enum CodingKeys: String, CodingKey {
        case id, score, scoreDate, components
        case activitiesCount, challengesCompleted
    }
}

// MARK: - Score Breakdown

public struct ScoreBreakdown: Codable {
    public let mediaLiteracy: Double
    public let politicalAwareness: Double
    public let cognitiveReflection: Double
    public let sourceEvaluation: Double
    public let biasRecognition: Double
    
    public enum CodingKeys: String, CodingKey {
        case mediaLiteracy, politicalAwareness, cognitiveReflection
        case sourceEvaluation, biasRecognition
    }
}

// MARK: - Score Components

public struct ScoreComponents: Codable {
    public let diversityScore: Double
    public let engagementScore: Double
    public let accuracyScore: Double
    public let reflectionScore: Double
    
    public enum CodingKeys: String, CodingKey {
        case diversityScore, engagementScore
        case accuracyScore, reflectionScore
    }
}

// MARK: - Score Insight

public struct ScoreInsight: Codable, Identifiable {
    public let id = UUID()
    public let type: InsightType
    public let title: String
    public let description: String
    public let recommendation: String?
    public let priority: InsightPriority
    
    public enum InsightType: String, Codable {
        case strength
        case weakness
        case opportunity
        case trend
    }
    
    public enum InsightPriority: String, Codable {
        case high
        case medium
        case low
    }
    
    public enum CodingKeys: String, CodingKey {
        case type, title, description, recommendation, priority
    }
}

// MARK: - Score Trend

public struct ScoreTrend: Codable {
    public let direction: TrendDirection
    public let changePercent: Double
    public let periodDays: Int
    
    public enum TrendDirection: String, Codable {
        case increasing
        case decreasing
        case stable
    }
    
    public enum CodingKeys: String, CodingKey {
        case direction, changePercent, periodDays
    }
}