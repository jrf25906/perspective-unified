import Foundation
import Combine

/**
 * Protocol defining the offline data manager interface
 * Handles offline data storage, caching, and synchronization
 */
public protocol OfflineDataManagerProtocol {
    var isOnline: Bool { get }
    var pendingSyncCount: Int { get }
    
    // User Preferences
    func saveUserPreferences(_ preferences: UserSyncPreferences)
    func getUserPreferences() -> UserSyncPreferences
    func updatePreference<T: Codable>(_ keyPath: WritableKeyPath<UserSyncPreferences, T>, value: T)
    func setOfflineModeEnabled(_ enabled: Bool)
    func isOfflineModeEnabled() -> Bool
    
    // Challenge Response Management
    func saveChallengeResponse(challengeId: Int, userAnswer: String, timeSpent: Int, isCorrect: Bool)
    
    // Challenge Caching
    func getCachedChallenge() -> Challenge?
    func getCachedChallenges() -> [Challenge]
    func cacheChallenge(_ challenge: Challenge)
    func cacheChallenges(_ challenges: [Challenge])
    
    // News Article Caching
    func cacheNewsArticles(_ articles: [NewsArticle])
    func getCachedNewsArticles() -> [NewsArticle]
    func getCachedNewsArticles(category: String?, limit: Int?) -> [NewsArticle]
    
    // Echo Score History Caching
    func cacheEchoScoreHistory(_ history: [EchoScoreHistory])
    func getCachedEchoScoreHistory() -> [EchoScoreHistory]
    func getLatestEchoScore() -> EchoScoreHistory?
    func getEchoScoreHistory(limit: Int?) -> [EchoScoreHistory]
    
    // Sync Management
    func getLastSyncDate() -> Date?
    
    // Cache Management
    func clearAllCache()
    func getCacheSize() -> Int
}

// Note: UserSyncPreferences is centrally defined in Models/PreferenceModels.swift 