import Foundation

/**
 * Centralized Preference Models
 * 
 * Provides single source of truth for all preference-related models
 * Prevents naming conflicts and ensures proper separation of concerns
 * 
 * SOLID Principles Applied:
 * - SRP: Each preference model has a single, clear purpose
 * - OCP: Models are open for extension through computed properties
 * - LSP: All models properly conform to Codable where needed
 * - ISP: Separate models for different preference domains
 * - DIP: Models depend on abstractions (Codable) not concrete implementations
 */

// MARK: - User Sync Preferences

/**
 * Preferences related to data synchronization and offline behavior
 * Used by OfflineDataManager and related sync services
 */
public struct UserSyncPreferences: Codable, Equatable {
    public var notificationsEnabled: Bool = true
    public var dailyChallengeReminder: Bool = true
    public var reminderTime: String = "09:00"
    public var preferredDifficulty: ChallengeDifficulty = .intermediate
    public var autoSyncEnabled: Bool = true
    public var offlineModeEnabled: Bool = false
    public var dataUsageOptimization: Bool = false
    public var biasAlertSensitivity: Double = 0.7
    public var themePreference: String = "system"
    public var language: String = "en"
    
    // Public initializer for external use
    public init() {}
    
    // MARK: - Computed Properties
    
    /// Check if any sync-related preferences are non-default
    public var hasCustomSyncSettings: Bool {
        return !autoSyncEnabled ||
               offlineModeEnabled ||
               dataUsageOptimization ||
               preferredDifficulty != .intermediate
    }
    
    /// Get reminder time as Date components
    public var reminderTimeComponents: DateComponents? {
        let components = reminderTime.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return nil }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }
    
    /// Validate reminder time format
    public var isValidReminderTime: Bool {
        return reminderTimeComponents != nil
    }
    
    // MARK: - Factory Methods
    
    /// Create preferences with custom settings
    public static func custom(
        notificationsEnabled: Bool = true,
        autoSyncEnabled: Bool = true,
        offlineModeEnabled: Bool = false,
        preferredDifficulty: ChallengeDifficulty = .intermediate
    ) -> UserSyncPreferences {
        var preferences = UserSyncPreferences()
        preferences.notificationsEnabled = notificationsEnabled
        preferences.autoSyncEnabled = autoSyncEnabled
        preferences.offlineModeEnabled = offlineModeEnabled
        preferences.preferredDifficulty = preferredDifficulty
        return preferences
    }
    
    /// Create offline-optimized preferences
    public static var offlineOptimized: UserSyncPreferences {
        var preferences = UserSyncPreferences()
        preferences.offlineModeEnabled = true
        preferences.autoSyncEnabled = false
        preferences.dataUsageOptimization = true
        return preferences
    }
    
    /// Create performance-optimized preferences
    public static var performanceOptimized: UserSyncPreferences {
        var preferences = UserSyncPreferences()
        preferences.autoSyncEnabled = true
        preferences.dataUsageOptimization = false
        preferences.notificationsEnabled = false
        return preferences
    }
}

// MARK: - Display Preferences Type Alias

/**
 * Type alias for the UI/display preferences
 * References the ObservableObject in Core/UserPreferences.swift
 */
public typealias UserDisplayPreferences = UserPreferences

// MARK: - App Settings

/**
 * General application settings that don't fit into other categories
 * Stored separately from user-specific preferences
 */
public struct AppSettings: Codable {
    public var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    public var lastUpdateCheck: Date?
    public var analyticsEnabled: Bool = false
    public var crashReportingEnabled: Bool = true
    public var debugModeEnabled: Bool = false
    public var serverEnvironment: ServerEnvironment = .production
    
    public init() {}
    
    public enum ServerEnvironment: String, Codable {
        case production = "production"
        case staging = "staging"
        case development = "development"
    }
}

// MARK: - Preference Categories

/**
 * Enum defining different preference categories
 * Used for organizing preferences in UI and storage
 */
public enum PreferenceCategory: String, CaseIterable {
    case sync = "Sync & Offline"
    case display = "Display & Theme"
    case notifications = "Notifications"
    case privacy = "Privacy & Security"
    case advanced = "Advanced"
    
    public var icon: String {
        switch self {
        case .sync: return "arrow.triangle.2.circlepath"
        case .display: return "paintbrush"
        case .notifications: return "bell"
        case .privacy: return "lock.shield"
        case .advanced: return "gearshape.2"
        }
    }
    
    public var description: String {
        switch self {
        case .sync: return "Manage data synchronization and offline behavior"
        case .display: return "Customize app appearance and theme"
        case .notifications: return "Configure notification preferences"
        case .privacy: return "Control privacy and security settings"
        case .advanced: return "Advanced settings and developer options"
        }
    }
}

// MARK: - Migration Support

/**
 * Helper to migrate from old UserPreferences to new structure
 */
public struct PreferenceMigration {
    /// Migrate from old combined preferences to new separated model
    public static func migrateIfNeeded() {
        // Check if migration is needed
        let migrationKey = "preference_migration_v2_completed"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        
        // Perform migration
        if let oldData = UserDefaults.standard.data(forKey: "user_preferences"),
           let oldPrefs = try? JSONDecoder().decode(UserSyncPreferences.self, from: oldData) {
            // Save migrated preferences
            if let newData = try? JSONEncoder().encode(oldPrefs) {
                UserDefaults.standard.set(newData, forKey: "user_sync_preferences")
            }
        }
        
        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
} 