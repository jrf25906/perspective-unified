import SwiftUI

// MARK: - Simple Preview Test
// This file tests if SwiftUI previews work with the design system

struct PreviewTestView: View {
    var body: some View {
        VStack(spacing: Perspective.spacing.lg) {
            Text("Preview Test")
                .perspectiveStyle(.displayMedium)
                .foregroundColor(Perspective.colors.deepInsightBlue)
            
            Perspective.Components.button("Test Button") {
                print("Button tapped")
            }
            
            HStack {
                Perspective.Components.echoScore(85, category: .cognitive)
                Perspective.Components.echoScore(72, category: .social)
            }
        }
        .perspectivePadding()
        .perspectiveScreen
    }
}

// MARK: - Basic Components Test

struct BasicComponentsTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: PerspectiveSpacing.md) {
                // Test basic colors
                HStack {
                    Rectangle()
                        .fill(PerspectiveColors.deepInsightBlue)
                        .frame(width: 50, height: 50)
                    
                    Rectangle()
                        .fill(PerspectiveColors.discoveryTeal)
                        .frame(width: 50, height: 50)
                    
                    Rectangle()
                        .fill(PerspectiveColors.achievementGold)
                        .frame(width: 50, height: 50)
                }
                
                // Test typography
                VStack(alignment: .leading) {
                    Text("Display Large")
                        .font(PerspectiveTypography.Display.large)
                    
                    Text("Body Medium")
                        .font(PerspectiveTypography.Body.medium)
                    
                    Text("Label Small")
                        .font(PerspectiveTypography.Label.small)
                }
                
                // Test doorway card
                VStack {
                    Text("Doorway Card Test")
                        .font(PerspectiveTypography.Headline.medium)
                    
                    Text("This card shows the lightSeeping state")
                        .font(PerspectiveTypography.Body.small)
                }
                .perspectiveCard(state: .lightSeeping)
            }
            .padding()
        }
        .background(PerspectiveColors.Semantic.background)
    }
}

// MARK: - Previews

#Preview("Design System Test") {
    PreviewTestView()
        .perspectiveDesignSystem()
}

#Preview("Basic Components") {
    BasicComponentsTest()
}

#Preview("Dark Mode Test") {
    PreviewTestView()
        .perspectiveDesignSystem()
        .preferredColorScheme(.dark)
}