import Foundation
import Combine

// Extension for offline functionality
extension APIService {
    
    // MARK: - Offline Challenge Support
    
    func submitChallengeOffline(challengeId: Int, userAnswer: Any, timeSpent: Int) -> AnyPublisher<ChallengeResult, APIError> {
        // Create offline submission result using centralized factory
        return Just(ChallengeResultFactory.createOfflineSubmissionResult())
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    }
    
    // MARK: - Offline Echo Score Support
    
    func getEchoScoreOffline() -> AnyPublisher<EchoScore, APIError> {
        // Create a default offline echo score
        let defaultScoreBreakdown = ScoreBreakdown(
            mediaLiteracy: 50.0,
            politicalAwareness: 50.0,
            cognitiveReflection: 50.0,
            sourceEvaluation: 50.0,
            biasRecognition: 50.0
        )
        
        let defaultInsights = [
            ScoreInsight(
                type: .opportunity,
                title: "Offline Mode",
                description: "Your score is showing offline data. Connect to sync your latest progress.",
                recommendation: "Connect to the internet to sync your latest scores",
                priority: .medium
            )
        ]
        
        let defaultTrend = ScoreTrend(
            direction: .stable,
            changePercent: 0.0,
            periodDays: 7
        )
        
        let offlineScore = EchoScore(
            currentScore: 50.0,
            scoreBreakdown: defaultScoreBreakdown,
            insights: defaultInsights,
            trend: defaultTrend,
            lastUpdated: Date()
        )
        
        return Just(offlineScore)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}