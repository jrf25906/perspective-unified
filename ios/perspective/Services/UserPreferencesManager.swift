import Foundation

/**
 * User Preferences Manager
 * 
 * Manages storage and retrieval of user sync preferences
 * Uses centralized UserSyncPreferences model from PreferenceModels.swift
 * 
 * SOLID Principles Applied:
 * - SRP: Single responsibility for preference persistence
 * - DRY: Uses centralized preference model
 */
public class UserPreferencesManager {
    private enum UserDefaultsKeys {
        static let userPreferences = "user_sync_preferences" // Updated key for migration
        static let offlineMode = "offline_mode_enabled"
    }
    
    // MARK: - Public Methods
    
    public func saveUserPreferences(_ preferences: UserSyncPreferences) {
        do {
            let data = try JSONEncoder().encode(preferences)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.userPreferences)
            print("User sync preferences saved successfully")
        } catch {
            print("Failed to save user sync preferences: \(error)")
        }
    }
    
    public func getUserPreferences() -> UserSyncPreferences {
        // Check for migration from old key
        PreferenceMigration.migrateIfNeeded()
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.userPreferences) else {
            return UserSyncPreferences() // Return default preferences
        }
        
        do {
            return try JSONDecoder().decode(UserSyncPreferences.self, from: data)
        } catch {
            print("Failed to decode user sync preferences: \(error)")
            return UserSyncPreferences() // Return default preferences on error
        }
    }
    
    public func updatePreference<T: Codable>(_ keyPath: WritableKeyPath<UserSyncPreferences, T>, value: T) {
        var preferences = getUserPreferences()
        preferences[keyPath: keyPath] = value
        saveUserPreferences(preferences)
    }
    
    // MARK: - Offline Mode
    
    public func setOfflineModeEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.offlineMode)
        updatePreference(\.offlineModeEnabled, value: enabled)
    }
    
    public func isOfflineModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.offlineMode)
    }
} 