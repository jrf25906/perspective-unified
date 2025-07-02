import SwiftUI
import Combine

struct TokenDebugView: View {
    @StateObject private var apiService = APIService.shared
    @State private var tokenInfo: String = "Loading..."
    @State private var keychainToken: String?
    @State private var userDefaultsToken: String?
    @State private var authServiceToken: String?
    @State private var timer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Token Debug Info")
                    .font(.title)
                    .bold()
                
                // Refresh button
                Button("Refresh Token Info") {
                    checkTokenStatus()
                }
                .buttonStyle(.borderedProminent)
                
                // Token Status
                GroupBox("Current Token Status") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Is Authenticated:")
                            Text(apiService.isAuthenticated ? "✅ Yes" : "❌ No")
                                .foregroundColor(apiService.isAuthenticated ? .green : .red)
                        }
                        
                        if let user = apiService.currentUser {
                            Text("User: \(user.email)")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Token Sources
                GroupBox("Token Sources") {
                    VStack(alignment: .leading, spacing: 12) {
                        // AuthService Token
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AuthService Token:")
                                .font(.headline)
                            if let token = authServiceToken {
                                Text(maskToken(token))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.blue)
                            } else {
                                Text("nil")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Divider()
                        
                        // Keychain Token
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Keychain Token:")
                                .font(.headline)
                            if let token = keychainToken {
                                Text(maskToken(token))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.blue)
                            } else {
                                Text("nil")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Divider()
                        
                        // UserDefaults Token
                        VStack(alignment: .leading, spacing: 4) {
                            Text("UserDefaults Token:")
                                .font(.headline)
                            if let token = userDefaultsToken {
                                Text(maskToken(token))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.blue)
                            } else {
                                Text("nil")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Test Request
                GroupBox("Test Authenticated Request") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Make Test Request") {
                            makeTestRequest()
                        }
                        .buttonStyle(.bordered)
                        
                        Text(tokenInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Actions
                GroupBox("Debug Actions") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Clear All Tokens") {
                            clearAllTokens()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        
                        Button("Force Re-authenticate") {
                            apiService.logout()
                            checkTokenStatus()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .onAppear {
            checkTokenStatus()
            // Auto-refresh every 2 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                checkTokenStatus()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func checkTokenStatus() {
        // Get token from AuthenticationService via reflection
        let authService = Mirror(reflecting: apiService).children.first { $0.label == "authService" }?.value
        if let authService = authService {
            let authMirror = Mirror(reflecting: authService)
            authServiceToken = authMirror.children.first { $0.label == "authToken" }?.value as? String
        }
        
        // Check Keychain directly
        keychainToken = UserDefaults.standard.string(forKey: "auth_token")
        
        // Check UserDefaults
        userDefaultsToken = UserDefaults.standard.string(forKey: "auth_token")
        
        // Debug info
        var info = "Token Check at \(Date().formatted(date: .omitted, time: .standard))\n"
        info += "AuthService has token: \(authServiceToken != nil ? "Yes" : "No")\n"
        
        if let token = authServiceToken {
            if token.contains("mock") {
                info += "⚠️ WARNING: Token contains 'mock'!\n"
            }
            if token == "mock-jwt-token-12345" {
                info += "🚨 ERROR: Using mock token!\n"
            }
        }
        
        tokenInfo = info
    }
    
    private func makeTestRequest() {
        tokenInfo = "Making authenticated request..."
        
        Task {
            do {
                // Try to get challenge to test auth
                _ = try await apiService.getTodayChallenge()
                tokenInfo = "✅ Request succeeded!"
            } catch {
                tokenInfo = "❌ Request failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func clearAllTokens() {
        // Clear from keychain
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
        UserDefaults.standard.synchronize()
        
        // Force logout
        apiService.logout()
        
        checkTokenStatus()
        tokenInfo = "All tokens cleared!"
    }
    
    private func maskToken(_ token: String) -> String {
        if token.count > 20 {
            let prefix = String(token.prefix(10))
            let suffix = String(token.suffix(10))
            return "\(prefix)...\(suffix)"
        }
        return token
    }
}

struct TokenDebugView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDebugView()
    }
}