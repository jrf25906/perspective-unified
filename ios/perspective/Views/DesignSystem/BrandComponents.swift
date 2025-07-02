import SwiftUI

// MARK: - Perspective Brand Components
// Reusable UI components based on the doorway metaphor and brand framework

// MARK: - Doorway Button

struct DoorwayButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    enum Style {
        case primary
        case secondary
        case portal
        case enlightened
    }
    
    var style: Style = .primary
    @State private var isPressed = false
    @State private var isHovering = false
    
    init(_ title: String, icon: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PerspectiveSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .perspectiveStyle(.labelLarge)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, PerspectiveSpacing.Components.buttonPaddingHorizontal)
            .padding(.vertical, PerspectiveSpacing.Components.buttonPaddingVertical)
            .background(backgroundView)
            .cornerRadius(PerspectiveSpacing.xl)
            .overlay(overlayView)
            .scaleEffect(isPressed ? 0.96 : (isHovering ? 1.02 : 1.0))
            .shadow(
                color: shadowColor.opacity(isHovering ? 0.3 : 0.15),
                radius: isHovering ? 12 : 6,
                x: 0,
                y: isHovering ? 6 : 3
            )
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(PerspectiveAnimations.buttonTap) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onHover { hovering in
            withAnimation(PerspectiveAnimations.TimingCurves.responsive) {
                isHovering = hovering
            }
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            PerspectiveColors.deepInsightBlue
        case .secondary:
            PerspectiveColors.discoveryTeal
        case .portal:
            PerspectiveColors.Gradients.portal
        case .enlightened:
            PerspectiveColors.Gradients.enlightenmentSpectrum
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .portal, .enlightened:
            return PerspectiveColors.mindClear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return PerspectiveColors.deepInsightBlue
        case .secondary:
            return PerspectiveColors.discoveryTeal
        case .portal:
            return PerspectiveColors.revelationPurple
        case .enlightened:
            return PerspectiveColors.achievementGold
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if style == .portal || style == .enlightened {
            RoundedRectangle(cornerRadius: PerspectiveSpacing.xl)
                .stroke(
                    LinearGradient(
                        colors: [
                            PerspectiveColors.achievementGold.opacity(0.5),
                            PerspectiveColors.revelationPurple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .blur(radius: 0.5)
        }
    }
}

// MARK: - Doorway Card

struct DoorwayCard<Content: View>: View {
    let content: () -> Content
    var state: DoorwayState = .closed
    var elevation: Int = 1
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .doorwayCardPadding()
        .background(cardBackground)
        .cornerRadius(PerspectiveSpacing.lg)
        .overlay(doorwayOverlay)
        .shadow(
            color: shadowColor,
            radius: CGFloat(elevation * 4),
            x: 0,
            y: CGFloat(elevation * 2)
        )
        .doorwayTransition(isOpen: state != .closed)
        .lightSeeping(intensity: lightIntensity)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch state {
        case .closed:
            PerspectiveColors.Semantic.surface
        case .lightSeeping:
            LinearGradient(
                colors: [
                    PerspectiveColors.Semantic.surface,
                    PerspectiveColors.discoveryTeal.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .opening:
            LinearGradient(
                colors: [
                    PerspectiveColors.discoveryTeal.opacity(0.1),
                    PerspectiveColors.revelationPurple.opacity(0.05)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .enlightened:
            PerspectiveColors.Gradients.subtleBackground
        }
    }
    
    @ViewBuilder
    private var doorwayOverlay: some View {
        if state == .enlightened {
            RoundedRectangle(cornerRadius: PerspectiveSpacing.lg)
                .stroke(
                    PerspectiveColors.Gradients.enlightenmentSpectrum,
                    lineWidth: 2
                )
                .blur(radius: 1)
        }
    }
    
    private var shadowColor: Color {
        switch state {
        case .closed:
            return Color.black.opacity(0.1)
        case .lightSeeping:
            return PerspectiveColors.discoveryTeal.opacity(0.2)
        case .opening:
            return PerspectiveColors.revelationPurple.opacity(0.25)
        case .enlightened:
            return PerspectiveColors.achievementGold.opacity(0.3)
        }
    }
    
    private var lightIntensity: Double {
        switch state {
        case .closed: return 0
        case .lightSeeping: return 0.5
        case .opening: return 0.8
        case .enlightened: return 1.0
        }
    }
}

// MARK: - Echo Score Display

struct EchoScoreDisplay: View {
    let score: Int
    let category: EchoCategory
    let size: Size
    
    enum Size {
        case small, medium, large, hero
        
        var textStyle: PerspectiveTextStyle.Style {
            switch self {
            case .small: return .dataSmall
            case .medium: return .dataMedium
            case .large: return .dataLarge
            case .hero: return .dataXLarge
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            case .hero: return 48
            }
        }
    }
    
    enum EchoCategory: CaseIterable, Hashable {
        case cognitive
        case social
        case practical
        case creative
        case analytical
        case overall
        
        var color: Color {
            switch self {
            case .cognitive: return PerspectiveColors.EchoScore.cognitive
            case .social: return PerspectiveColors.EchoScore.social
            case .practical: return PerspectiveColors.EchoScore.practical
            case .creative: return PerspectiveColors.EchoScore.creative
            case .analytical: return PerspectiveColors.EchoScore.analytical
            case .overall: return PerspectiveColors.achievementGold
            }
        }
        
        var icon: String {
            switch self {
            case .cognitive: return "brain"
            case .social: return "person.2.fill"
            case .practical: return "hammer.fill"
            case .creative: return "paintbrush.fill"
            case .analytical: return "chart.line.uptrend.xyaxis"
            case .overall: return "star.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: PerspectiveSpacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: size.iconSize))
                .foregroundColor(category.color)
            
            Text("\(score)")
                .perspectiveStyle(size.textStyle)
                .foregroundColor(category.color)
                .shadow(color: category.color.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, PerspectiveSpacing.md)
        .padding(.vertical, PerspectiveSpacing.sm)
        .background(
            Capsule()
                .fill(category.color.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(category.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Portal Loading View

struct PortalLoadingView: View {
    @State private var rotation = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        PerspectiveColors.Gradients.enlightenmentSpectrum,
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 120)
                    .rotationEffect(.degrees(rotation + Double(index * 120)))
                    .scaleEffect(scale)
                    .opacity(0.8 - Double(index) * 0.2)
            }
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 3)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.2
            }
        }
    }
}

// MARK: - Insight Pill

struct InsightPill: View {
    let text: String
    let icon: String?
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: PerspectiveSpacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
            }
            
            Text(text)
                .perspectiveStyle(.labelSmall)
        }
        .foregroundColor(
            isSelected ? PerspectiveColors.mindClear : PerspectiveColors.deepInsightBlue
        )
        .padding(.horizontal, PerspectiveSpacing.md)
        .padding(.vertical, PerspectiveSpacing.sm)
        .background(
            Capsule()
                .fill(
                    isSelected
                        ? PerspectiveColors.deepInsightBlue
                        : PerspectiveColors.deepInsightBlue.opacity(0.1)
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    PerspectiveColors.deepInsightBlue.opacity(isSelected ? 0 : 0.3),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Progress Observatory

struct ProgressObservatory: View {
    let scores: [EchoScoreDisplay.EchoCategory: Int]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background portal effect
                PerspectiveColors.Gradients.portal
                    .opacity(0.2)
                
                // Score windows arranged in a circle
                ForEach(Array(scores.keys.enumerated()), id: \.element) { index, category in
                    if let score = scores[category] {
                        ScoreWindow(
                            category: category,
                            score: score,
                            angle: angleForIndex(index, total: scores.count),
                            radius: min(geometry.size.width, geometry.size.height) * 0.35
                        )
                    }
                }
                
                // Center overall score
                if let overallScore = scores[.overall] {
                    EchoScoreDisplay(
                        score: overallScore,
                        category: .overall,
                        size: .hero
                    )
                    .scaleEffect(1.2)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let step = 360.0 / Double(total)
        return Double(index) * step - 90
    }
}

struct ScoreWindow: View {
    let category: EchoScoreDisplay.EchoCategory
    let score: Int
    let angle: Double
    let radius: CGFloat
    
    var body: some View {
        EchoScoreDisplay(score: score, category: category, size: .small)
            .offset(
                x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius
            )
            .rotationEffect(.degrees(angle + 90))
    }
}

// MARK: - Achievement Burst View

struct AchievementBurstView: View {
    let achievement: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: PerspectiveSpacing.lg) {
            ZStack {
                // Burst rays
                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(PerspectiveColors.achievementGold)
                        .frame(width: 4, height: isAnimating ? 150 : 20)
                        .offset(y: isAnimating ? -75 : -10)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .opacity(isAnimating ? 0 : 0.8)
                        .animation(
                            PerspectiveAnimations.achievementBurst
                                .delay(Double(index) * 0.05),
                            value: isAnimating
                        )
                }
                
                // Achievement icon
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(PerspectiveColors.achievementGold)
                    .scaleEffect(isAnimating ? 1.5 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(
                        PerspectiveAnimations.TimingCurves.bouncy
                            .speed(0.5),
                        value: isAnimating
                    )
            }
            
            Text(achievement)
                .perspectiveStyle(.displaySmall)
                .foregroundColor(PerspectiveColors.achievementGold)
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(
                    PerspectiveAnimations.TimingCurves.gentle
                        .delay(0.3),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}