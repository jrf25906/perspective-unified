import SwiftUI

struct ContentView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var offlineDataManager: OfflineDataManager
    @State private var showWelcome = true
    
    // Explicit initializer to avoid ambiguity
    init() {}
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView {
                    withAnimation {
                        showWelcome = false
                    }
                }
                .onAppear {
                    print("🟢 Showing WelcomeView")
                }
            } else if apiService.isAuthenticated {
                ZStack {
                    MainTabView()
                        .environmentObject(appStateManager)
                    
                    // Offline indicator
                    if !networkMonitor.isConnected {
                        VStack {
                            Spacer()
                            OfflineIndicatorView()
                                .padding(.bottom, 100) // Above tab bar
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: networkMonitor.isConnected)
                    }
                    
                    // Sync indicator
                    if offlineDataManager.pendingSyncCount > 0 && networkMonitor.isConnected {
                        VStack {
                            SyncIndicatorView(pendingCount: offlineDataManager.pendingSyncCount)
                                .padding(.top, 50)
                            Spacer()
                        }
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: offlineDataManager.pendingSyncCount)
                    }
                }
                .onAppear {
                    print("🔵 Showing MainTabView - User is authenticated")
                }
            } else {
                AuthenticationView()
                    .onAppear {
                        print("🔴 Showing AuthenticationView - User not authenticated")
                    }
            }
        }
        .perspectiveDesignSystem() // Initialize Perspective design system
        .onAppear {
            print("📱 ContentView onAppear - showWelcome: \(showWelcome), isAuthenticated: \(apiService.isAuthenticated)")
            // Check authentication status on app launch
            if apiService.isAuthenticated {
                print("✅ User already authenticated, skipping welcome")
                showWelcome = false // Skip welcome if already authenticated
            } else {
                print("❌ User not authenticated, fetching profile")
                apiService.fetchProfile()
            }
        }
    }
}

struct OfflineIndicatorView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(Perspective.colors.mindClear)
            Text("You're offline")
                .perspectiveStyle(.labelMedium)
                .foregroundColor(Perspective.colors.mindClear)
        }
        .padding(.horizontal, Perspective.spacing.md)
        .padding(.vertical, Perspective.spacing.sm)
        .background(Perspective.colors.achievementGold) // More brand-aligned than orange
        .cornerRadius(12)
        .shadow(
            color: Perspective.colors.achievementGold.opacity(0.3),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

struct SyncIndicatorView: View {
    let pendingCount: Int
    
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: Perspective.colors.mindClear))
            
            Text("Syncing \(pendingCount) item\(pendingCount == 1 ? "" : "s")...")
                .perspectiveStyle(.captionLarge)
                .foregroundColor(Perspective.colors.mindClear)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Perspective.colors.discoveryTeal) // Brand-aligned sync color
        .cornerRadius(8)
        .shadow(
            color: Perspective.colors.discoveryTeal.opacity(0.3),
            radius: 2,
            x: 0,
            y: 1
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(APIService.shared)
            .environmentObject(AppStateManager.shared)
            .environmentObject(NetworkMonitor.shared)
            .environmentObject(OfflineDataManager())
    }
}
