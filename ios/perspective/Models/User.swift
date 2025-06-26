import Foundation

public struct User: Codable, Identifiable {
    public let id: Int
    public let email: String
    public let username: String
    public let firstName: String?
    public let lastName: String?
    public let avatarUrl: String?
    public let isActive: Bool?
    public let emailVerified: Bool?
    public let echoScore: Double
    public let biasProfile: BiasProfile?
    public let preferredChallengeTime: String?
    public let currentStreak: Int
    public let lastActivityDate: Date?
    public let createdAt: Date
    public let updatedAt: Date?
    public let lastLoginAt: Date?
    public let role: String?
    public let deletedAt: Date?
    public let googleId: String?
    
    public enum CodingKeys: String, CodingKey {
        case id, email, username
        case firstName
        case lastName
        case avatarUrl
        case isActive
        case emailVerified
        case echoScore
        case biasProfile
        case preferredChallengeTime
        case currentStreak
        case lastActivityDate
        case createdAt
        case updatedAt
        case lastLoginAt
        case role
        case deletedAt
        case googleId
    }
    
    // MARK: - Memberwise Initializer
    
    /**
     * Memberwise initializer for programmatic User creation
     * Used by APIService for user updates and modifications
     */
    public init(
        id: Int,
        email: String,
        username: String,
        firstName: String? = nil,
        lastName: String? = nil,
        avatarUrl: String? = nil,
        isActive: Bool? = nil,
        emailVerified: Bool? = nil,
        echoScore: Double = 0.0,
        biasProfile: BiasProfile? = nil,
        preferredChallengeTime: String? = nil,
        currentStreak: Int = 0,
        lastActivityDate: Date? = nil,
        createdAt: Date,
        updatedAt: Date? = nil,
        lastLoginAt: Date? = nil,
        role: String? = nil,
        deletedAt: Date? = nil,
        googleId: String? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
        self.isActive = isActive
        self.emailVerified = emailVerified
        self.echoScore = echoScore
        self.biasProfile = biasProfile
        self.preferredChallengeTime = preferredChallengeTime
        self.currentStreak = currentStreak
        self.lastActivityDate = lastActivityDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.role = role
        self.deletedAt = deletedAt
        self.googleId = googleId
    }
    
    // MARK: - Custom Decoding
    
    /**
     * Custom decoder that handles backend data inconsistencies
     * Provides robust handling of string/number type mismatches
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Debug: Print all available keys
        print("🔍 Available keys in container: \(container.allKeys.map { $0.stringValue })")
        print("🔍 Looking for echo_score key: \(CodingKeys.echoScore.stringValue)")
        print("🔍 Container contains echo_score: \(container.contains(.echoScore))")
        
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        
        // Handle boolean fields that might come as integers
        if let isActiveInt = try? container.decode(Int.self, forKey: .isActive) {
            isActive = isActiveInt != 0
        } else {
            isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        }
        
        if let emailVerifiedInt = try? container.decode(Int.self, forKey: .emailVerified) {
            emailVerified = emailVerifiedInt != 0
        } else {
            emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        }
        
        // Handle echo_score with comprehensive debugging
        do {
            if let echoScoreString = try? container.decode(String.self, forKey: .echoScore) {
                print("🎯 Successfully decoded echo_score as string: '\(echoScoreString)'")
                echoScore = Double(echoScoreString) ?? 0.0
                print("🎯 Converted to double: \(echoScore)")
            } else if let echoScoreDouble = try? container.decode(Double.self, forKey: .echoScore) {
                print("🎯 Successfully decoded echo_score as double: \(echoScoreDouble)")
                echoScore = echoScoreDouble
            } else {
                print("❌ Could not decode echo_score as string or double, using default")
                echoScore = 0.0
            }
        } catch {
            print("❌ Error in echo_score handling: \(error)")
            echoScore = 0.0
        }
        
        biasProfile = try container.decodeIfPresent(BiasProfile.self, forKey: .biasProfile)
        preferredChallengeTime = try container.decodeIfPresent(String.self, forKey: .preferredChallengeTime)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        lastActivityDate = try container.decodeIfPresent(Date.self, forKey: .lastActivityDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        lastLoginAt = try container.decodeIfPresent(Date.self, forKey: .lastLoginAt)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        googleId = try container.decodeIfPresent(String.self, forKey: .googleId)
    }
}

public struct BiasProfile: Codable {
    public let initialAssessmentScore: Double
    public let politicalLean: Double // -3 to +3 scale
    public let preferredSources: [String]
    public let blindSpots: [String]
    public let assessmentDate: Date
    
    public enum CodingKeys: String, CodingKey {
        case initialAssessmentScore
        case politicalLean
        case preferredSources
        case blindSpots
        case assessmentDate
    }
}

public struct AuthResponse: Codable {
    public let user: User
    public let token: String
}

public struct LoginRequest: Codable {
    public let email: String
    public let password: String
}

public struct RegisterRequest: Codable {
    public let email: String
    public let username: String
    public let password: String
    public let firstName: String?
    public let lastName: String?
    
    public enum CodingKeys: String, CodingKey {
        case email, username, password
        case firstName
        case lastName
    }
}

public struct GoogleSignInRequest: Codable {
    public let idToken: String
    
    public enum CodingKeys: String, CodingKey {
        case idToken
    }
}

public struct UserStatistics {
    public let totalChallengesCompleted: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let averageAccuracy: Double
    public let totalTimeSpent: Int // in minutes
    public let joinDate: Date
}

// MARK: - User Extensions

public extension User {
    /**
     * Create a copy of the user with updated avatar URL
     * Used for avatar management operations
     */
    func withUpdatedAvatar(_ avatarUrl: String?) -> User {
        return User(
            id: self.id,
            email: self.email,
            username: self.username,
            firstName: self.firstName,
            lastName: self.lastName,
            avatarUrl: avatarUrl,
            isActive: self.isActive,
            emailVerified: self.emailVerified,
            echoScore: self.echoScore,
            biasProfile: self.biasProfile,
            preferredChallengeTime: self.preferredChallengeTime,
            currentStreak: self.currentStreak,
            lastActivityDate: self.lastActivityDate,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            lastLoginAt: self.lastLoginAt,
            role: self.role,
            deletedAt: self.deletedAt,
            googleId: self.googleId
        )
    }
    
    /**
     * Get user's display name
     */
    var displayName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else {
            return username
        }
    }
    
    /**
     * Get user's initials for avatar fallback
     */
    var initials: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
        } else if let firstName = firstName {
            return String(firstName.prefix(2)).uppercased()
        } else {
            return String(username.prefix(2)).uppercased()
        }
    }
}
