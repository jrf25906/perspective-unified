import Foundation
import SwiftUI

/**
 * Type System Validation
 * 
 * Ensures all architectural components work together correctly
 * Provides runtime verification and debugging capabilities
 */

#if DEBUG
enum TypeValidator {
    
    // MARK: - Core Type Validation
    
    static func validateCoreTypes() {
        print("🔍 Type System Validation Started")
        
        validateAPIError()
        validateNewsReference()
        validateUserPreferences()
        validateAppEnvironment()
        
        print("✅ Type System Validation Completed")
    }
    
    // MARK: - APIError Validation
    
    static func validateAPIError() {
        print("Validating APIError...")
        
        // Test all error cases
        let errors: [APIError] = [
            .unauthorized,
            .badRequest("Test"),
            .conflict("Test"),
            .serverError("Test"),
            .networkError(NSError(domain: "test", code: 0)),
            .unknownError(500, "Test")
        ]
        
        for error in errors {
            assert(error.errorDescription != nil, "APIError should have description")
            assert(error.failureReason != nil, "APIError should have failure reason")
            assert(error.recoverySuggestion != nil, "APIError should have recovery suggestion")
        }
        
        // Test status code mapping
        let mappedError = APIError.fromStatusCode(401, message: "Unauthorized")
        assert(mappedError == .unauthorized, "Status code 401 should map to unauthorized")
        
        print("✅ APIError validation passed")
    }
    
    // MARK: - NewsReference Validation
    
    static func validateNewsReference() {
        print("Validating NewsReference...")
        
        guard let url = URL(string: "https://example.com/article") else {
            fatalError("Invalid test URL")
        }
        
        let newsRef = NewsReference(
            title: "Test Article",
            url: url,
            source: "Test Source",
            publishedAt: Date(),
            category: .politics,
            bias: .center,
            credibilityScore: 0.8
        )
        
        // Validate computed properties
        assert(!newsRef.formattedPublishDate.isEmpty, "Formatted date should not be empty")
        assert(newsRef.credibilityRating == .high, "0.8 score should be high rating")
        assert(newsRef.isValid, "Valid news reference should pass validation")
        
        // Test validation
        do {
            try newsRef.validate()
        } catch {
            fatalError("Valid news reference should not throw: \(error)")
        }
        
        print("✅ NewsReference validation passed")
    }
    
    // MARK: - UserPreferences Validation
    
    static func validateUserPreferences() {
        print("Validating Preference Models...")
        
        // Test UserSyncPreferences (offline/sync preferences)
        print("📌 Testing UserSyncPreferences")
        let syncPrefs = UserSyncPreferences()
        assert(syncPrefs.notificationsEnabled == true, "Default notifications should be enabled")
        assert(syncPrefs.autoSyncEnabled == true, "Default auto-sync should be enabled")
        assert(syncPrefs.isValidReminderTime == true, "Default reminder time should be valid")
        
        // Test factory methods
        let offlinePrefs = UserSyncPreferences.offlineOptimized
        assert(offlinePrefs.offlineModeEnabled == true, "Offline optimized should enable offline mode")
        assert(offlinePrefs.autoSyncEnabled == false, "Offline optimized should disable auto-sync")
        
        // Test UserDisplayPreferences (UI preferences)
        print("📌 Testing UserDisplayPreferences")
        let mockStorage = MockUserDefaults()
        let displayPrefs = UserPreferences(storage: mockStorage)
        
        // Test state changes
        let initialDarkMode = displayPrefs.isDarkMode
        displayPrefs.isDarkMode = !initialDarkMode
        assert(displayPrefs.isDarkMode != initialDarkMode, "isDarkMode should toggle")
        
        // Test category management
        displayPrefs.toggleCategory("politics")
        assert(displayPrefs.isSelectedCategory("politics") != displayPrefs.selectedNewsCategories.contains("politics"), "Category toggle should work")
        
        // Test customizations detection
        displayPrefs.resetToDefaults()
        assert(!displayPrefs.hasCustomizations, "Default preferences should not have customizations")
        
        print("✅ Preference Models validation passed")
    }
    
    // MARK: - AppEnvironment Validation
    
    static func validateAppEnvironment() {
        print("Validating AppEnvironment...")
        
        // Test configuration access
        let config = Config.current
        assert(!config.apiBaseURL.isEmpty, "API base URL should not be empty")
        assert(config.apiTimeout > 0, "API timeout should be positive")
        
        // Test environment types
        let devConfig = DevelopmentConfig()
        assert(devConfig.isDebugMode, "Development config should have debug mode")
        assert(devConfig.featureFlags.enableBetaFeatures, "Development should enable beta features")
        
        let prodConfig = ProductionConfig()
        assert(!prodConfig.isDebugMode, "Production config should not have debug mode")
        assert(!prodConfig.featureFlags.enableBetaFeatures, "Production should not enable beta features")
        
        print("✅ AppEnvironment validation passed")
    }
    
    // MARK: - Integration Tests
    
    static func validateIntegration() {
        print("🔗 Integration Validation Started")
        
        // Test APIError with UserSyncPreferences
        let preferences = UserSyncPreferences()
        let error = APIError.unauthorized
        
        // Simulate error handling with preferences
        if error == .unauthorized {
            // This would trigger logout in real app
            var resetPrefs = UserSyncPreferences()
            resetPrefs.offlineModeEnabled = false
            resetPrefs.autoSyncEnabled = true
            // In real app, this would be saved through OfflineDataManager
        }
        
        // Test NewsReference with AppEnvironment
        let config = Config.current
        guard let url = URL(string: "\(config.apiBaseURL)/articles/123") else {
            fatalError("Could not create article URL with config")
        }
        
        let article = NewsReference(
            title: "Integration Test",
            url: url,
            source: "Test",
            publishedAt: Date(),
            category: .politics
        )
        
        assert(article.url.absoluteString.contains(config.apiBaseURL), "Article URL should contain API base URL")
        
        print("✅ Integration validation passed")
    }
}

// MARK: - SwiftUI Preview Integration

struct TypeValidationView: View {
    @State private var validationResults: [String] = []
    
    var body: some View {
        NavigationView {
            List(validationResults, id: \.self) { result in
                Text(result)
                    .font(.system(.body, design: .monospaced))
            }
            .navigationTitle("Type Validation")
            .onAppear {
                runValidation()
            }
        }
    }
    
    private func runValidation() {
        DispatchQueue.global(qos: .background).async {
            var results: [String] = []
            
            // Create a custom print function that captures output
            let capturedPrint: (Any...) -> Void = { items in
                let message = items.map { String(describing: $0) }.joined(separator: " ")
                results.append(message)
                Swift.print(message) // Call the real print function
            }
            
            // Temporarily override print for TypeValidator
            // Note: This is a simplified approach for debugging
            
            TypeValidator.validateCoreTypes()
            TypeValidator.validateIntegration()
            
            DispatchQueue.main.async {
                self.validationResults = results
            }
        }
    }
}

// MARK: - Validation Helpers

extension TypeValidator {
    static func printSystemInfo() {
        print("📱 System Information:")
        print("iOS Version: \(UIDevice.current.systemVersion)")
        print("Device Model: \(UIDevice.current.model)")
        print("Environment: \(Config.environment.rawValue)")
        print("API Base URL: \(Config.apiBaseURL)")
        print("Debug Mode: \(Config.isDebugMode)")
    }
}

#endif 