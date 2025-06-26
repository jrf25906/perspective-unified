import Foundation
import SwiftUI
import Combine

/**
 * UserPreferences ObservableObject
 * 
 * SOLID Principles Applied:
 * - SRP: Manages user preference state only
 * - OCP: Extensible through computed properties and methods
 * - LSP: Properly conforms to ObservableObject
 * - ISP: Focused interface for preference management
 * - DIP: Depends on UserDefaults abstraction
 */

public class UserPreferences: ObservableObject {
    // MARK: - Published Properties
    @Published public var isDarkMode: Bool {
        didSet {
            storage.set(isDarkMode, forKey: Keys.isDarkMode)
        }
    }
    
    @Published public var notificationsEnabled: Bool {
        didSet {
            storage.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published public var selectedNewsCategories: Set<String> {
        didSet {
            storage.set(Array(selectedNewsCategories), forKey: Keys.selectedNewsCategories)
        }
    }
    
    @Published public var preferredLanguage: String {
        didSet {
            storage.set(preferredLanguage, forKey: Keys.preferredLanguage)
        }
    }
    
    @Published public var autoRefreshInterval: TimeInterval {
        didSet {
            storage.set(autoRefreshInterval, forKey: Keys.autoRefreshInterval)
        }
    }
    
    @Published public var biasDisplayMode: BiasDisplayMode {
        didSet {
            storage.set(biasDisplayMode.rawValue, forKey: Keys.biasDisplayMode)
        }
    }
    
    // MARK: - Private Properties
    private let storage: UserDefaultsProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private enum Keys {
        static let isDarkMode = "user_preferences_dark_mode"
        static let notificationsEnabled = "user_preferences_notifications"
        static let selectedNewsCategories = "user_preferences_categories"
        static let preferredLanguage = "user_preferences_language"
        static let autoRefreshInterval = "user_preferences_refresh_interval"
        static let biasDisplayMode = "user_preferences_bias_display"
    }
    
    // MARK: - Nested Types
    public enum BiasDisplayMode: String, CaseIterable, Codable {
        case always = "always"
        case onHover = "on_hover"
        case never = "never"
        
        public var displayName: String {
            switch self {
            case .always: return "Always Show"
            case .onHover: return "Show on Tap"
            case .never: return "Never Show"
            }
        }
    }
    
    // MARK: - Initialization
    public init(storage: UserDefaultsProtocol = UserDefaultsWrapper()) {
        self.storage = storage
        
        // Load saved preferences or use defaults
        self.isDarkMode = storage.bool(forKey: Keys.isDarkMode)
        self.notificationsEnabled = storage.bool(forKey: Keys.notificationsEnabled)
        self.preferredLanguage = storage.string(forKey: Keys.preferredLanguage) ?? "en"
        self.autoRefreshInterval = storage.double(forKey: Keys.autoRefreshInterval) != 0 ? 
            storage.double(forKey: Keys.autoRefreshInterval) : 300 // 5 minutes default
        
        // Load selected categories
        let defaultCategories = ["politics", "economy", "technology", "climate", "healthcare", "education"]
        let categoryStrings = storage.stringArray(forKey: Keys.selectedNewsCategories) ?? defaultCategories
        self.selectedNewsCategories = Set(categoryStrings)
        
        // Load bias display mode
        let biasDisplayString = storage.string(forKey: Keys.biasDisplayMode) ?? BiasDisplayMode.onHover.rawValue
        self.biasDisplayMode = BiasDisplayMode(rawValue: biasDisplayString) ?? .onHover
    }
    
    // MARK: - Public Methods
    public func resetToDefaults() {
        isDarkMode = false
        notificationsEnabled = true
        selectedNewsCategories = Set(["politics", "economy", "technology", "climate", "healthcare", "education"])
        preferredLanguage = "en"
        autoRefreshInterval = 300
        biasDisplayMode = .onHover
    }
    
    public func toggleCategory(_ category: String) {
        if selectedNewsCategories.contains(category) {
            selectedNewsCategories.remove(category)
        } else {
            selectedNewsCategories.insert(category)
        }
    }
    
    public func isSelectedCategory(_ category: String) -> Bool {
        return selectedNewsCategories.contains(category)
    }
    
    // MARK: - Computed Properties
    public var hasCustomizations: Bool {
        let defaultCategories = Set(["politics", "economy", "technology", "climate", "healthcare", "education"])
        return isDarkMode ||
               !notificationsEnabled ||
               selectedNewsCategories != defaultCategories ||
               preferredLanguage != "en" ||
               autoRefreshInterval != 300 ||
               biasDisplayMode != .onHover
    }
    
    public var formattedRefreshInterval: String {
        let minutes = Int(autoRefreshInterval / 60)
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }
}

// MARK: - UserDefaults Protocol
public protocol UserDefaultsProtocol {
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func stringArray(forKey defaultName: String) -> [String]?
    func double(forKey defaultName: String) -> Double
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: String?, forKey defaultName: String)
    func set(_ value: [String], forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)
}

// MARK: - UserDefaults Wrapper
public class UserDefaultsWrapper: UserDefaultsProtocol {
    private let userDefaults = UserDefaults.standard
    
    // Public initializer required for default argument in UserPreferences
    public init() {}
    
    public func bool(forKey defaultName: String) -> Bool {
        return userDefaults.bool(forKey: defaultName)
    }
    
    public func string(forKey defaultName: String) -> String? {
        return userDefaults.string(forKey: defaultName)
    }
    
    public func stringArray(forKey defaultName: String) -> [String]? {
        return userDefaults.stringArray(forKey: defaultName)
    }
    
    public func double(forKey defaultName: String) -> Double {
        return userDefaults.double(forKey: defaultName)
    }
    
    public func set(_ value: Bool, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
    
    public func set(_ value: String?, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
    
    public func set(_ value: [String], forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
    
    public func set(_ value: Double, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
}

// MARK: - Preview Support
#if DEBUG
extension UserPreferences {
    static let preview: UserPreferences = {
        let prefs = UserPreferences(storage: MockUserDefaults())
        prefs.isDarkMode = true
        prefs.selectedNewsCategories = Set(["politics", "technology"])
        return prefs
    }()
}

class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }
    
    func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
    
    func stringArray(forKey defaultName: String) -> [String]? {
        return storage[defaultName] as? [String]
    }
    
    func double(forKey defaultName: String) -> Double {
        return storage[defaultName] as? Double ?? 0.0
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func set(_ value: String?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func set(_ value: [String], forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func set(_ value: Double, forKey defaultName: String) {
        storage[defaultName] = value
    }
}
#endif 