import Foundation

enum AppConfig {
    static let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    
    // Add more environment variables as needed
    static let isDebug = true
    static let apiTimeout: TimeInterval = 30
} 