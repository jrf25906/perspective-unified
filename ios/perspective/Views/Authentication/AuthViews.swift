import SwiftUI
import Combine

/**
 * Authentication Views Re-export Module
 * 
 * Temporary workaround for Xcode target membership issues
 * This file consolidates all authentication views in one place
 * 
 * ARCHITECTURAL NOTE:
 * This is a tactical solution while we fix the project structure.
 * Once files are properly added to target, this can be removed.
 */

// MARK: - Re-export Authentication Views

/**
 * Ensures all authentication views are accessible
 * Works around file system synchronized group issues
 */
public enum AuthViews {
    
    // Re-export LoginView inline
    public struct Login: View {
        @EnvironmentObject var apiService: APIService
        @State private var email = ""
        @State private var password = ""
        @State private var isLoading = false
        @State private var errorMessage: String?
        @State private var cancellables = Set<AnyCancellable>()
        
        public init() {}
        
        public var body: some View {
            // Delegate to actual LoginView
            LoginView()
        }
    }
    
    // Re-export RegisterView inline
    public struct Register: View {
        public init() {}
        
        public var body: some View {
            RegisterView()
        }
    }
    
    // Re-export QuickLoginView inline
    public struct QuickLogin: View {
        public init() {}
        
        public var body: some View {
            QuickLoginView()
        }
    }
}

// MARK: - Alternative: Direct Type Aliases

/// Type aliases as an alternative approach
/// Use these if the above doesn't work
public typealias PerspectiveLoginView = LoginView
public typealias PerspectiveRegisterView = RegisterView
public typealias PerspectiveQuickLoginView = QuickLoginView

// MARK: - Module Verification

/**
 * Verifies that all views are properly accessible
 */
public struct AuthModuleVerification {
    
    public static func verify() -> Bool {
        // Try to instantiate each view
        _ = LoginView()
        _ = RegisterView()
        _ = QuickLoginView()
        
        return true
    }
    
    public static func printDiagnostics() {
        print("🔍 Authentication Module Diagnostics:")
        print("   LoginView: \(String(describing: LoginView.self))")
        print("   RegisterView: \(String(describing: RegisterView.self))")
        print("   QuickLoginView: \(String(describing: QuickLoginView.self))")
    }
} 