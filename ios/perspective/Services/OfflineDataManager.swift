import Foundation
import Combine

public final class OfflineDataManager: ObservableObject, OfflineDataManagerProtocol {
    public static let shared = OfflineDataManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var isOnline = true
    @Published public var pendingSyncCount = 0
    
    private let userPreferencesManager: UserPreferencesManager
    private let cacheManager: CacheManager
    private let syncManager: SyncManager
    
    // UserSyncPreferences is now centrally defined in Models/PreferenceModels.swift
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let cachedChallenges = "cached_challenges"
        static let cachedNewsArticles = "cached_news_articles"
        static let cachedEchoScoreHistory = "cached_echo_score_history"
        static let challengeResponses = "challenge_responses"
        static let userPreferences = "user_preferences"
        static let lastSyncDate = "last_sync_date"
        static let offlineMode = "offline_mode_enabled"
    }
    
    // UserPreferences is defined via typealias above
    
    // MARK: - Challenge Response Storage
    struct ChallengeResponse: Codable {
        let challengeId: Int
        let userAnswer: String
        let timeSpent: Int
        let isCorrect: Bool
        let submittedAt: Date
        let syncStatus: SyncStatus
    }
    
    enum SyncStatus: String, Codable {
        case pending
        case synced
        case failed
    }
    
    public init() {
        self.userPreferencesManager = UserPreferencesManager()
        self.cacheManager = CacheManager()
        self.syncManager = SyncManager(cacheManager: cacheManager, apiService: APIService.shared)
        
        // Bind sync manager's pending count
        syncManager.$pendingSyncCount
            .assign(to: &$pendingSyncCount)
        
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
                if isConnected {
                    self?.syncManager.syncPendingData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Preferences (Delegated)
    
    public func saveUserPreferences(_ preferences: UserSyncPreferences) {
        userPreferencesManager.saveUserPreferences(preferences)
    }
    
    public func getUserPreferences() -> UserSyncPreferences {
        return userPreferencesManager.getUserPreferences()
    }
    
    public func updatePreference<T: Codable>(_ keyPath: WritableKeyPath<UserSyncPreferences, T>, value: T) {
        userPreferencesManager.updatePreference(keyPath, value: value)
    }
    
    public func setOfflineModeEnabled(_ enabled: Bool) {
        userPreferencesManager.setOfflineModeEnabled(enabled)
    }
    
    public func isOfflineModeEnabled() -> Bool {
        return userPreferencesManager.isOfflineModeEnabled()
    }
    
    // MARK: - Challenge Response Management (Delegated)
    
    public func saveChallengeResponse(challengeId: Int, userAnswer: String, timeSpent: Int, isCorrect: Bool) {
        syncManager.saveChallengeResponse(
            challengeId: challengeId,
            userAnswer: userAnswer,
            timeSpent: timeSpent,
            isCorrect: isCorrect,
            isOnline: isOnline
        )
    }
    
    // MARK: - Challenge Caching (Delegated)
    
    public func getCachedChallenge() -> Challenge? {
        return cacheManager.getCachedChallenge()
    }
    
    public func getCachedChallenges() -> [Challenge] {
        return cacheManager.getCachedChallenges()
    }
    
    public func cacheChallenge(_ challenge: Challenge) {
        cacheManager.cacheChallenge(challenge)
    }
    
    public func cacheChallenges(_ challenges: [Challenge]) {
        cacheManager.cacheChallenges(challenges)
    }
    
    // Additional methods for APIService compatibility
    func getCachedDailyChallenge() -> Challenge? {
        return getCachedChallenge()
    }
    
    func cacheDailyChallenge(_ challenge: Challenge) {
        cacheChallenge(challenge)
    }
    
    func queueChallengeSubmission(challengeId: Int, submission: ChallengeSubmission) {
        // Convert the submission to a format we can store
        let answer = (submission.answer.value as? String) ?? ""
        saveChallengeResponse(
            challengeId: challengeId,
            userAnswer: answer,
            timeSpent: submission.timeSpentSeconds,
            isCorrect: false // Will be determined when synced
        )
    }
    
    // MARK: - News Article Caching (Delegated)
    
    public func cacheNewsArticles(_ articles: [NewsArticle]) {
        cacheManager.cacheNewsArticles(articles)
    }
    
    public func getCachedNewsArticles() -> [NewsArticle] {
        return cacheManager.getCachedNewsArticles()
    }
    
    public func getCachedNewsArticles(category: String? = nil, limit: Int? = nil) -> [NewsArticle] {
        return cacheManager.getCachedNewsArticles(category: category, limit: limit)
    }
    
    // MARK: - Echo Score History Caching (Delegated)
    
    public func cacheEchoScoreHistory(_ history: [EchoScoreHistory]) {
        cacheManager.cacheEchoScoreHistory(history)
    }
    
    public func getCachedEchoScoreHistory() -> [EchoScoreHistory] {
        return cacheManager.getCachedEchoScoreHistory()
    }
    
    public func getLatestEchoScore() -> EchoScoreHistory? {
        return cacheManager.getLatestEchoScore()
    }
    
    public func getEchoScoreHistory(limit: Int? = nil) -> [EchoScoreHistory] {
        return cacheManager.getEchoScoreHistory(limit: limit)
    }
    
    // MARK: - Sync Management (Delegated)
    
    public func getLastSyncDate() -> Date? {
        return syncManager.getLastSyncDate()
    }
    
    // MARK: - Cache Management (Delegated)
    
    public func clearAllCache() {
        cacheManager.clearAllCache()
        syncManager.clearPendingData()
    }
    
    public func getCacheSize() -> Int {
        return cacheManager.getCacheSize()
    }
}