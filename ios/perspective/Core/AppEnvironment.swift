import Foundation
import SwiftUI

/**
 * Application Environment Configuration
 * 
 * SOLID Principles Applied:
 * - SRP: Manages environment configuration only
 * - OCP: Extensible for new environments
 * - LSP: All environments implement same interface
 * - ISP: Focused configuration interface
 * - DIP: Depends on abstractions not concretions
 */

// MARK: - Environment Protocol
protocol EnvironmentConfigurable {
    var apiBaseURL: String { get }
    var isDebugMode: Bool { get }
    var apiTimeout: TimeInterval { get }
    var logLevel: LogLevel { get }
    var featureFlags: FeatureFlags { get }
}

// MARK: - Environment Types
enum AppEnvironment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    var configuration: EnvironmentConfigurable {
        switch self {
        case .development:
            return DevelopmentConfig()
        case .staging:
            return StagingConfig()
        case .production:
            return ProductionConfig()
        }
    }
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
}

// MARK: - Log Level
enum LogLevel: String, CaseIterable {
    case verbose = "verbose"
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case none = "none"
    
    var priority: Int {
        switch self {
        case .verbose: return 0
        case .debug: return 1
        case .info: return 2
        case .warning: return 3
        case .error: return 4
        case .none: return 5
        }
    }
}

// MARK: - Feature Flags
struct FeatureFlags {
    let enableBetaFeatures: Bool
    let enableAnalytics: Bool
    let enableCrashReporting: Bool
    let enableOfflineMode: Bool
    let enablePushNotifications: Bool
    let enableBiometricAuth: Bool
    
    static let development = FeatureFlags(
        enableBetaFeatures: true,
        enableAnalytics: false,
        enableCrashReporting: false,
        enableOfflineMode: true,
        enablePushNotifications: true,
        enableBiometricAuth: true
    )
    
    static let staging = FeatureFlags(
        enableBetaFeatures: true,
        enableAnalytics: true,
        enableCrashReporting: true,
        enableOfflineMode: true,
        enablePushNotifications: true,
        enableBiometricAuth: true
    )
    
    static let production = FeatureFlags(
        enableBetaFeatures: false,
        enableAnalytics: true,
        enableCrashReporting: true,
        enableOfflineMode: true,
        enablePushNotifications: true,
        enableBiometricAuth: true
    )
}

// MARK: - Development Configuration
struct DevelopmentConfig: EnvironmentConfigurable {
    let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    let isDebugMode = true
    let apiTimeout: TimeInterval = 30
    let logLevel = LogLevel.verbose
    let featureFlags = FeatureFlags.development
}

// MARK: - Staging Configuration
struct StagingConfig: EnvironmentConfigurable {
    let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    let isDebugMode = true
    let apiTimeout: TimeInterval = 30
    let logLevel = LogLevel.debug
    let featureFlags = FeatureFlags.staging
}

// MARK: - Production Configuration
struct ProductionConfig: EnvironmentConfigurable {
    let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    let isDebugMode = false
    let apiTimeout: TimeInterval = 15
    let logLevel = LogLevel.warning
    let featureFlags = FeatureFlags.production
}

// MARK: - Global Configuration Access
enum Config {
    static let environment = AppEnvironment.current
    static let current = environment.configuration
    
    // Convenience accessors
    static var apiBaseURL: String {
        return current.apiBaseURL
    }
    
    static var isDebugMode: Bool {
        return current.isDebugMode
    }
    
    static var apiTimeout: TimeInterval {
        return current.apiTimeout
    }
    
    static var logLevel: LogLevel {
        return current.logLevel
    }
    
    static var featureFlags: FeatureFlags {
        return current.featureFlags
    }
}

// MARK: - SwiftUI Environment Integration
struct EnvironmentConfigKey: EnvironmentKey {
    static let defaultValue: EnvironmentConfigurable = Config.current
}

extension EnvironmentValues {
    var appConfig: EnvironmentConfigurable {
        get { self[EnvironmentConfigKey.self] }
        set { self[EnvironmentConfigKey.self] = newValue }
    }
}

// MARK: - Environment Modifier
extension View {
    func withAppEnvironment(_ config: EnvironmentConfigurable? = nil) -> some View {
        self.environment(\.appConfig, config ?? Config.current)
    }
}

// MARK: - Debug Utilities
#if DEBUG
extension Config {
    static func override(with config: EnvironmentConfigurable) {
        // This would typically use a mutable configuration system
        // For now, it's a placeholder for testing purposes
        print("⚠️ Environment override: \(config)")
    }
    
    static func reset() {
        // Reset to default configuration
        print("🔄 Environment reset to default")
    }
}

// MARK: - Mock Configuration for Testing
struct MockConfig: EnvironmentConfigurable {
    let apiBaseURL = "https://mock.api.test"
    let isDebugMode = true
    let apiTimeout: TimeInterval = 5
    let logLevel = LogLevel.verbose
    let featureFlags = FeatureFlags.development
}
#endif 