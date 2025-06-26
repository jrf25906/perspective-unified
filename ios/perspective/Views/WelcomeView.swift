import SwiftUI

struct WelcomeView: View {
    @State private var showContinueButton = false
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            VideoBackgroundView(videoName: "welcome_bg", videoType: "mp4")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack {
                Spacer()
                
                if showContinueButton {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
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