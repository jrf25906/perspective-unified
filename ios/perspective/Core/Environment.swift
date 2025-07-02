import Foundation

enum AppConfig {
    // TEMPORARY: Using local backend due to Railway deployment issue
    // TODO: Revert to Railway URL once deployment is fixed
    static let apiBaseURL = "http://localhost:3000/api/v1"
    
    // Production URL (uncomment when Railway deployment is fixed):
    // static let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    
    // Add more environment variables as needed
    static let isDebug = true
    static let apiTimeout: TimeInterval = 30
} 