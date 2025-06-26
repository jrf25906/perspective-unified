import Foundation

public struct NewsArticle: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let summary: String
    public let content: String
    public let source: String
    public let sourceUrl: String?
    public let author: String?
    public let category: String
    public let imageUrl: String?
    public let publishedAt: Date
    public let credibilityScore: Double
    public let biasIndicators: [String]
    public let readingTimeMinutes: Int
    
    public enum CodingKeys: String, CodingKey {
        case id, title, summary, content, source
        case sourceUrl, author, category, imageUrl
        case publishedAt, credibilityScore, biasIndicators
        case readingTimeMinutes
    }
}