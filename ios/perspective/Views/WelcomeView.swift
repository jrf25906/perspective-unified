import SwiftUI

struct WelcomeView: View {
    @State private var showContinueButton = false
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Brand-aligned enlightenment gradient background
            Perspective.colors.Gradients.enlightenmentSpectrum
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack {
                // App branding that shows immediately
                VStack(spacing: Perspective.spacing.lg) {
                    // Doorway-inspired icon using brand elements
                    Image(systemName: "door.left.hand.open")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Perspective.colors.mindClear, Perspective.colors.mindClear.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Perspective.colors.achievementGold.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Perspective")
                        .perspectiveStyle(.displayLarge)
                        .foregroundColor(Perspective.colors.mindClear)
                    
                    Text("Every perspective is a doorway.\nWe help you find the keys.")
                        .perspectiveStyle(.bodyLarge)
                        .foregroundColor(Perspective.colors.mindClear.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 100)
                
                Spacer()
                
                // Show doorway-style continue button
                if showContinueButton {
                    Perspective.Components.button(
                        "Open the First Doorway",
                        icon: "arrow.right",
                        style: .enlightened,
                        action: onContinue
                    )
                    .padding(.horizontal, 64)
                    .padding(.bottom, 80)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            print("🟢 WelcomeView appeared")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("🟢 Setting showContinueButton to true")
                withAnimation(Perspective.animations.doorwayOpen) {
                    showContinueButton = true
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(onContinue: {})
    }
}