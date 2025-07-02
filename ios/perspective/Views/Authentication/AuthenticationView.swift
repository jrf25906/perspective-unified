import SwiftUI
import AVKit

// NOTE: If LoginView and QuickLoginView are not found, ensure they are:
// 1. Added to the perspective target in Xcode's target membership
// 2. Part of the same module/framework
// 3. Have their target membership checkbox enabled in File Inspector

public struct AuthenticationView: View {
    @State private var isLoginMode = true
    @State private var showQuickLogin = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Simple gradient background instead of video
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle blue tint to differentiate from WelcomeView
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack { // Branding overlay
                VStack(spacing: 16) {
                    Image(systemName: "eye.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Perspective")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Escape echo chambers.\nBuild cognitive flexibility.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .padding(.bottom, 32)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            NavigationView {
                VStack(spacing: 20) {
                    // Authentication forms
                    if isLoginMode {
                        LoginView()
                    } else {
                        RegisterView()
                    }
                    // Toggle between login and register
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoginMode.toggle()
                        }
                    }) {
                        Text(isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Sign in")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 20)
                    // Debug quick login button
                    Button(action: {
                        showQuickLogin = true
                    }) {
                        Text("Debug: Quick Login Test")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .sheet(isPresented: $showQuickLogin) {
                        QuickLoginView()
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 28)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                        .shadow(radius: 18)
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 48)
                .navigationBarHidden(true)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(APIService.shared)
            .environmentObject(AppStateManager.shared)
            .environmentObject(NetworkMonitor.shared)
            .environmentObject(OfflineDataManager.shared)
    }
}

/*
 Environment Object Setup Instructions:

 To ensure `AuthenticationView` and related views work properly, you must inject the following environment objects into the view hierarchy.

 1. In a SwiftUI App (`@main`):

    @main
    struct YourAppName: App {
        var body: some Scene {
            WindowGroup {
                AuthenticationView()
                    .environmentObject(APIService.shared)
                    .environmentObject(AppStateManager.shared)
                    .environmentObject(NetworkMonitor.shared)
                    .environmentObject(OfflineDataManager.shared)
            }
        }
    }

 2. In a UIKit App using SceneDelegate:

    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?

        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                let rootView = AuthenticationView()
                    .environmentObject(APIService.shared)
                    .environmentObject(AppStateManager.shared)
                    .environmentObject(NetworkMonitor.shared)
                    .environmentObject(OfflineDataManager.shared)

                window.rootViewController = UIHostingController(rootView: rootView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }

 This setup ensures all dependent views receive their necessary environment objects.
*/
