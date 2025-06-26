import Foundation

/**
 * NewsReference Domain Model
 * 
 * SOLID Principles Applied:
 * - SRP: Represents news article reference data only
 * - OCP: Extensible through computed properties
 * - LSP: Conforms to standard protocols
 * - ISP: Focused interface without unnecessary dependencies
 * - DIP: Depends on Foundation abstractions only
 */

struct NewsReference: Codable, Identifiable, Equatable, Hashable {
    // MARK: - Core Properties
    let id: String
    let title: String
    let url: URL
    let source: String
    let publishedAt: Date
    let summary: String?
    
    // MARK: - Metadata
    let category: NewsCategory
    let bias: PoliticalBias
    let credibilityScore: Double
    
    // MARK: - Optional Properties
    let imageUrl: URL?
    let author: String?
    let readTime: Int? // minutes
    
    // MARK: - Computed Properties
    var formattedPublishDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: publishedAt)
    }
    
    var isRecent: Bool {
        let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return publishedAt > twentyFourHoursAgo
    }
    
    var credibilityRating: CredibilityRating {
        switch credibilityScore {
        case 0.8...1.0: return .high
        case 0.6..<0.8: return .medium
        case 0.4..<0.6: return .low
        default: return .unknown
        }
    }
    
    // MARK: - Nested Types
    enum NewsCategory: String, Codable, CaseIterable {
        case politics = "politics"
        case economy = "economy"
        case technology = "technology"
        case climate = "climate"
        case healthcare = "healthcare"
        case education = "education"
        case international = "international"
        case local = "local"
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
    
    enum PoliticalBias: String, Codable, CaseIterable {
        case left = "left"
        case leanLeft = "lean_left"
        case center = "center"
        case leanRight = "lean_right"
        case right = "right"
        case unknown = "unknown"
        
        var displayName: String {
            switch self {
            case .left: return "Left"
            case .leanLeft: return "Lean Left"
            case .center: return "Center"
            case .leanRight: return "Lean Right"
            case .right: return "Right"
            case .unknown: return "Unknown"
            }
        }
        
        var color: String {
            switch self {
            case .left: return "#0066CC"
            case .leanLeft: return "#6699FF"
            case .center: return "#808080"
            case .leanRight: return "#FF6666"
            case .right: return "#CC0000"
            case .unknown: return "#999999"
            }
        }
    }
    
    enum CredibilityRating: String, CaseIterable {
        case high = "high"
        case medium = "medium"
        case low = "low"
        case unknown = "unknown"
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
    
    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        title: String,
        url: URL,
        source: String,
        publishedAt: Date,
        summary: String? = nil,
        category: NewsCategory,
        bias: PoliticalBias = .unknown,
        credibilityScore: Double = 0.5,
        imageUrl: URL? = nil,
        author: String? = nil,
        readTime: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.source = source
        self.publishedAt = publishedAt
        self.summary = summary
        self.category = category
        self.bias = bias
        self.credibilityScore = min(max(credibilityScore, 0.0), 1.0) // Clamp between 0-1
        self.imageUrl = imageUrl
        self.author = author
        self.readTime = readTime
    }
    
    // MARK: - Custom Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case source
        case publishedAt = "published_at"
        case summary
        case category
        case bias
        case credibilityScore = "credibility_score"
        case imageUrl = "image_url"
        case author
        case readTime = "read_time"
    }
}

// MARK: - Factory Methods
extension NewsReference {
    static func createSample() -> NewsReference {
        return NewsReference(
            title: "Sample News Article",
            url: URL(string: "https://example.com/article")!,
            source: "Sample News",
            publishedAt: Date(),
            summary: "This is a sample news article for testing purposes.",
            category: .politics,
            bias: .center,
            credibilityScore: 0.8
        )
    }
}

// MARK: - Validation Extensions
extension NewsReference {
    var isValid: Bool {
        return !title.isEmpty &&
               !source.isEmpty &&
               credibilityScore >= 0.0 &&
               credibilityScore <= 1.0
    }
    
    func validate() throws {
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        
        guard !source.isEmpty else {
            throw ValidationError.emptySource
        }
        
        guard credibilityScore >= 0.0 && credibilityScore <= 1.0 else {
            throw ValidationError.invalidCredibilityScore
        }
    }
    
    enum ValidationError: LocalizedError {
        case emptyTitle
        case emptySource
        case invalidCredibilityScore
        
        var errorDescription: String? {
            switch self {
            case .emptyTitle:
                return "News article title cannot be empty"
            case .emptySource:
                return "News article source cannot be empty"
            case .invalidCredibilityScore:
                return "Credibility score must be between 0.0 and 1.0"
            }
        }
    }
} 