import Foundation
import Combine

public final class APIService: ObservableObject, APIServiceProtocol {
    public static let shared = APIService()
    
    private let baseURL: String
    private let networkClient: NetworkClient
    private let requestBuilder: RequestBuilder
    private let authService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    @Published var isOffline = false
    
    private init() {
        // Configure base URL based on environment
        self.baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? Config.apiBaseURL
        
        print("🔧 APIService initialized with base URL: \(self.baseURL)")
        
        self.networkClient = NetworkClient()
        self.requestBuilder = RequestBuilder(baseURL: baseURL)
        self.authService = AuthenticationService(baseURL: baseURL)
        
        // Bind authentication state
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$currentUser
            .assign(to: &$currentUser)
        
        // Monitor network status
        setupNetworkMonitoring()
        
        // Listen for token expiration
        NotificationCenter.default.publisher(for: .authTokenExpired)
            .sink { [weak self] _ in
                self?.handleTokenExpiration()
            }
            .store(in: &cancellables)
        
        // Check for stored token on init
        authService.checkAuthentication()
    }
    
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.$isConnected
            .map { !$0 }
            .assign(to: &$isOffline)
    }
    
    private func handleTokenExpiration() {
        // Clear current auth state
        authService.logout()
        
        // TODO: Implement token refresh logic here
        // For now, just notify the user they need to log in again
        NotificationCenter.default.post(
            name: .userNeedsToReauthenticate,
            object: nil
        )
    }
    
    // MARK: - Authentication
    
    public func register(email: String, username: String, password: String, firstName: String? = nil, lastName: String? = nil) -> AnyPublisher<AuthResponse, APIError> {
        return authService.register(
            email: email,
            username: username,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
    }
    
    public func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError> {
        return authService.login(email: email, password: password)
    }
    
    public func googleSignIn(idToken: String) -> AnyPublisher<AuthResponse, APIError> {
        return authService.googleSignIn(idToken: idToken)
    }
    
    public func logout() {
        authService.logout()
    }
    
    public func fetchProfile() {
        authService.fetchProfile()
    }
    
    func refreshTokenIfNeeded() -> AnyPublisher<Bool, Never> {
        return authService.refreshTokenIfNeeded()
    }
    
    // MARK: - Challenges
    
    public func getTodayChallenge() -> AnyPublisher<Challenge, APIError> {
        // Check offline cache first if offline
        if isOffline {
            if let cachedChallenge = OfflineDataManager.shared.getCachedDailyChallenge() {
                return Just(cachedChallenge)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        return makeAuthenticatedRequest(
            endpoint: "/challenge/today",
            method: .GET,
            body: Optional<String>.none,
            responseType: Challenge.self
        )
        .handleEvents(
            receiveOutput: { challenge in
                // Cache the challenge for offline use
                OfflineDataManager.shared.cacheDailyChallenge(challenge)
                print("✅ Successfully decoded challenge: \(challenge.title)")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Challenge loading failed: \(error.localizedDescription)")
                    
                    // Additional logging for decoding errors
                    if case APIError.decodingError = error {
                        print("❌ This is a decoding error. Check console output for detailed error info.")
                        print("❌ Common causes:")
                        print("   - Backend sending different field names than expected")
                        print("   - Date format mismatch")
                        print("   - Missing required fields")
                        print("   - Type mismatches (e.g., string instead of int)")
                    }
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    public func submitChallenge(challengeId: Int, userAnswer: Any, timeSpent: Int) -> AnyPublisher<ChallengeResult, APIError> {
        let submission = ChallengeSubmission(
            answer: AnyCodable(userAnswer),
            timeSpentSeconds: timeSpent,
            confidence: nil,
            reasoning: nil
        )
        
        // Handle offline submission
        if isOffline {
            // Queue for later sync
            OfflineDataManager.shared.queueChallengeSubmission(
                challengeId: challengeId,
                submission: submission
            )
            
            // Return optimistic response using centralized factory
            let optimisticResult = ChallengeResultFactory.createOptimisticResult()
            
            return Just(optimisticResult)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        return makeAuthenticatedRequest(
            endpoint: "/challenge/\(challengeId)/submit",
            method: .POST,
            body: submission,
            responseType: ChallengeResult.self
        )
    }
    
    public func getChallengeStats() -> AnyPublisher<ChallengeStats, APIError> {
        return makeAuthenticatedRequest(
            endpoint: "/challenge/stats",
            method: .GET,
            body: Optional<String>.none,
            responseType: ChallengeStats.self
        )
    }
    
    public func getLeaderboard(timeframe: String = "weekly") -> AnyPublisher<[LeaderboardEntry], APIError> {
        return makeAuthenticatedRequest(
            endpoint: "/challenge/leaderboard?timeframe=\(timeframe)",
            method: .GET,
            body: Optional<String>.none,
            responseType: [LeaderboardEntry].self
        )
    }
    
    // MARK: - Echo Score
    
    public func getEchoScore() -> AnyPublisher<EchoScore, APIError> {
        return makeAuthenticatedRequest(
            endpoint: "/profile/echo-score",
            method: .GET,
            body: Optional<String>.none,
            responseType: EchoScore.self
        )
    }
    
    public func getEchoScoreHistory(days: Int = 30) -> AnyPublisher<[EchoScoreHistory], APIError> {
        return makeAuthenticatedRequest(
            endpoint: "/profile/echo-score/history?days=\(days)",
            method: .GET,
            body: Optional<String>.none,
            responseType: [EchoScoreHistory].self
        )
    }
    
    // MARK: - Avatar Management
    
    func uploadAvatar(imageData: Data) -> AnyPublisher<AvatarUploadResponse, APIError> {
        guard let token = authService.authToken else {
            return Fail(error: APIError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try requestBuilder.buildMultipartRequest(
                endpoint: "/avatar/upload",
                method: .POST,
                fileData: imageData,
                fileName: "avatar.jpg",
                mimeType: "image/jpeg",
                fieldName: "avatar",
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            return networkClient.performRequest(request, responseType: AvatarUploadResponse.self)
                .handleEvents(receiveOutput: { [weak self] response in
                    // Update current user's avatar URL
                    self?.updateUserAvatarUrl(response.avatarUrl)
                })
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    func deleteAvatar() -> AnyPublisher<AvatarDeletionResponse, APIError> {
        guard let token = authService.authToken else {
            return Fail(error: APIError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try requestBuilder.buildRequest(
                endpoint: "/avatar",
                method: .DELETE,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            return networkClient.performRequest(request, responseType: AvatarDeletionResponse.self)
                .handleEvents(receiveOutput: { [weak self] _ in
                    // Clear current user's avatar URL
                    self?.updateUserAvatarUrl(nil)
                })
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    func getAvatarUrl(for userId: Int? = nil) -> AnyPublisher<AvatarUrlResponse, APIError> {
        let endpoint = userId != nil ? "/avatar/\(userId!)" : "/avatar"
        var headers: [String: String] = [:]
        
        // Only add auth token if getting own avatar
        if userId == nil, let token = authService.authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        do {
            let request = try requestBuilder.buildRequest(
                endpoint: endpoint,
                method: .GET,
                headers: headers.isEmpty ? [:] : headers
            )
            
            return networkClient.performRequest(request, responseType: AvatarUrlResponse.self)
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Activity Management
    
    func getRecentActivities(limit: Int = 10) -> AnyPublisher<RecentActivitiesResponse, APIError> {
        guard let token = authService.authToken else {
            return Fail(error: APIError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try requestBuilder.buildRequest(
                endpoint: "/activity/recent?limit=\(limit)",
                method: .GET,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            return networkClient.performRequest(request, responseType: RecentActivitiesResponse.self)
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    func getActivitySummary(limit: Int = 20) -> AnyPublisher<ActivitySummaryResponse, APIError> {
        guard let token = authService.authToken else {
            return Fail(error: APIError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try requestBuilder.buildRequest(
                endpoint: "/activity/summary?limit=\(limit)",
                method: .GET,
                headers: ["Authorization": "Bearer \(token)"]
            )
            
            return networkClient.performRequest(request, responseType: ActivitySummaryResponse.self)
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    func getPublicActivityFeed(limit: Int = 50, offset: Int = 0) -> AnyPublisher<PublicActivityFeedResponse, APIError> {
        do {
            let request = try requestBuilder.buildRequest(
                endpoint: "/activity/feed?limit=\(limit)&offset=\(offset)",
                method: .GET
            )
            
            return networkClient.performRequest(request, responseType: PublicActivityFeedResponse.self)
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Private Methods
    
    private func makeAuthenticatedRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil,
        responseType: U.Type
    ) -> AnyPublisher<U, APIError> {
        guard let token = authService.authToken else {
            return Fail(error: APIError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        do {
            let request: URLRequest
            if let body = body {
                request = try requestBuilder.buildRequest(
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    headers: ["Authorization": "Bearer \(token)"]
                )
            } else {
                request = try requestBuilder.buildRequest(
                    endpoint: endpoint,
                    method: method,
                    headers: ["Authorization": "Bearer \(token)"]
                )
            }
            
            return networkClient.performRequest(request, responseType: responseType)
                .catch { [weak self] error -> AnyPublisher<U, APIError> in
                    // Handle specific errors
                    if case APIError.unauthorized = error {
                        self?.handleTokenExpiration()
                    }
                    return Fail(error: error).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? APIError ?? APIError.encodingError)
                .eraseToAnyPublisher()
        }
    }
    
    private func updateUserAvatarUrl(_ avatarUrl: String?) {
        if let user = currentUser {
            currentUser = user.withUpdatedAvatar(avatarUrl)
            authService.updateCachedUser(currentUser!)
        }
    }
}

// MARK: - Notification Names Extension
// Note: userNeedsToReauthenticate is centrally defined in PerspectiveCore.swift

// MARK: - Async/Await Extensions

extension APIService {
    
    // MARK: - Challenge Methods
    
    func getTodayChallenge() async throws -> Challenge {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getTodayChallenge()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { challenge in
                        continuation.resume(returning: challenge)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    func getChallengeStats() async throws -> ChallengeStats? {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getChallengeStats()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { stats in
                        continuation.resume(returning: stats)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    func submitChallenge(challengeId: Int, userAnswer: Any, timeSpent: Int) async throws -> ChallengeResult {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = submitChallenge(challengeId: challengeId, userAnswer: userAnswer, timeSpent: timeSpent)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { result in
                        continuation.resume(returning: result)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Achievement Methods
    
    func getUserAchievements() async throws -> [Achievement]? {
        // For now, return mock data until the backend endpoint is ready
        return [
            Achievement(
                id: "first_challenge",
                title: "First Steps",
                description: "Complete your first challenge",
                icon: "foot.2",
                category: .milestone,
                rarity: .common,
                requirement: AchievementRequirement(
                    type: .challengesCompleted,
                    value: 1,
                    timeframe: .allTime
                ),
                reward: AchievementReward(
                    type: .echoPoints,
                    value: 50
                ),
                isEarned: true,
                earnedDate: Date(),
                progress: 1,
                maxProgress: 1
            )
        ]
    }
}

// MARK: - Response Models

struct AvatarUploadResponse: Codable {
    let success: Bool
    let avatarUrl: String
    let message: String
}

struct AvatarUrlResponse: Codable {
    let userId: Int
    let avatarUrl: String?
    let hasAvatar: Bool
}

struct AvatarDeletionResponse: Codable {
    let success: Bool
    let message: String
}

// Note: SuccessResponse is centrally defined in APIModels.swift as generic type

struct RecentActivitiesResponse: Codable {
    let success: Bool
    let data: RecentActivitiesData
}

struct RecentActivitiesData: Codable {
    let activities: [ActivityEvent]
    let totalCount: Int
}

struct ActivitySummaryResponse: Codable {
    let success: Bool
    let data: ActivitySummary
}

struct ActivitySummary: Codable {
    let totalActivities: Int
    let recentActivities: [ActivityEvent]
    let activitiesByType: [String: Int]
    let activitiesByCategory: [String: Int]
    let lastActivityDate: Date?
}

struct PublicActivityFeedResponse: Codable {
    let success: Bool
    let data: PublicActivityFeedData
}

struct PublicActivityFeedData: Codable {
    let activities: [ActivityEvent]
    let limit: Int
    let offset: Int
    let hasMore: Bool
}

struct ActivityEvent: Codable {
    let id: Int?
    let userId: Int
    let type: String
    let title: String
    let description: String
    let metadata: [String: AnyCodable]?
    let xpEarned: Int?
    let timestamp: Date
    let category: String
    let visibility: String
}