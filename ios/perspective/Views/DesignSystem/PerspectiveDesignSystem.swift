import SwiftUI

// MARK: - Perspective Design System Foundation
// Central hub for all design system components with backward compatibility

/// Main design system namespace that provides easy access to all brand elements
struct Perspective {
    /// Brand colors following the Enlightenment Spectrum
    static let colors = PerspectiveColors.self
    
    /// Typography system with Inter, Space Grotesk, and JetBrains Mono
    static let typography = PerspectiveTypography.self
    
    /// Consistent spacing values based on 4pt grid
    static let spacing = PerspectiveSpacing.self
    
    /// Brand animations and transitions
    static let animations = PerspectiveAnimations.self
}

// MARK: - Backward Compatibility Bridge
// Ensures existing code continues to work while gradually migrating to new system

extension Perspective {
    /// Legacy color mappings for backward compatibility
    struct LegacyColors {
        // Map old Material3 colors to new brand colors
        static let primary = PerspectiveColors.deepInsightBlue
        static let primaryContainer = PerspectiveColors.Semantic.primaryContainer
        static let onPrimary = PerspectiveColors.Semantic.onPrimary
        static let onPrimaryContainer = PerspectiveColors.Semantic.onPrimaryContainer
        
        static let secondary = PerspectiveColors.discoveryTeal
        static let secondaryContainer = PerspectiveColors.Semantic.secondaryContainer
        static let onSecondary = PerspectiveColors.Semantic.onSecondary
        static let onSecondaryContainer = PerspectiveColors.Semantic.onSecondaryContainer
        
        static let tertiary = PerspectiveColors.revelationPurple
        static let tertiaryContainer = PerspectiveColors.Semantic.tertiaryContainer
        static let onTertiary = PerspectiveColors.Semantic.onTertiary
        static let onTertiaryContainer = PerspectiveColors.Semantic.onTertiaryContainer
        
        static let error = PerspectiveColors.Semantic.error
        static let errorContainer = PerspectiveColors.Semantic.errorContainer
        static let onError = PerspectiveColors.Semantic.onError
        static let onErrorContainer = PerspectiveColors.Semantic.onErrorContainer
        
        static let success = PerspectiveColors.achievementGold
        static let successContainer = PerspectiveColors.Semantic.successContainer
        static let onSuccess = PerspectiveColors.Semantic.onSuccess
        static let onSuccessContainer = PerspectiveColors.Semantic.onSuccessContainer
        
        static let surface = PerspectiveColors.Semantic.surface
        static let surfaceVariant = PerspectiveColors.Semantic.surfaceVariant
        static let onSurface = PerspectiveColors.Semantic.onSurface
        static let onSurfaceVariant = PerspectiveColors.Semantic.onSurfaceVariant
        
        static let outline = PerspectiveColors.Semantic.outline
        static let outlineVariant = PerspectiveColors.Semantic.outlineVariant
        
        static let inverseSurface = PerspectiveColors.Semantic.inverseSurface
        static let inverseOnSurface = PerspectiveColors.Semantic.inverseOnSurface
        static let inversePrimary = PerspectiveColors.Semantic.inversePrimary
    }
    
    /// Legacy typography mappings
    struct LegacyTypography {
        static let displayLarge = PerspectiveTypography.Display.large
        static let displayMedium = PerspectiveTypography.Display.medium
        static let displaySmall = PerspectiveTypography.Display.small
        
        static let headlineLarge = PerspectiveTypography.Headline.large
        static let headlineMedium = PerspectiveTypography.Headline.medium
        static let headlineSmall = PerspectiveTypography.Headline.small
        
        static let titleLarge = PerspectiveTypography.Title.large
        static let titleMedium = PerspectiveTypography.Title.medium
        static let titleSmall = PerspectiveTypography.Title.small
        
        static let bodyLarge = PerspectiveTypography.Body.large
        static let bodyMedium = PerspectiveTypography.Body.medium
        static let bodySmall = PerspectiveTypography.Body.small
        
        static let labelLarge = PerspectiveTypography.Label.large
        static let labelMedium = PerspectiveTypography.Label.medium
        static let labelSmall = PerspectiveTypography.Label.small
    }
    
    /// Legacy spacing mappings
    struct LegacySpacing {
        static let none = PerspectiveSpacing.none
        static let extraSmall = PerspectiveSpacing.xs
        static let small = PerspectiveSpacing.sm
        static let medium = PerspectiveSpacing.md
        static let large = PerspectiveSpacing.lg
        static let extraLarge = PerspectiveSpacing.xl
        static let xxLarge = PerspectiveSpacing.xxl
        static let xxxLarge = PerspectiveSpacing.xxxl
    }
}

// MARK: - Enhanced Material3 Compatibility
// Material3 colors are now updated directly in Material3DesignSystem.swift to use Perspective brand colors
// This maintains backward compatibility without extension conflicts

// MARK: - Design System Components Namespace

extension Perspective {
    /// Brand-specific UI components
    struct Components {
        /// Doorway-style button with brand styling
        static func button(
            _ title: String,
            icon: String? = nil,
            style: DoorwayButton.Style = .primary,
            action: @escaping () -> Void
        ) -> DoorwayButton {
            DoorwayButton(title, icon: icon, style: style, action: action)
        }
        
        /// Doorway-style card container
        static func card<Content: View>(
            state: DoorwayState = .closed,
            elevation: Int = 1,
            @ViewBuilder content: @escaping () -> Content
        ) -> DoorwayCard<Content> {
            DoorwayCard(content: content, state: state, elevation: elevation)
        }
        
        /// Echo score display component
        static func echoScore(
            _ score: Int,
            category: EchoScoreDisplay.EchoCategory,
            size: EchoScoreDisplay.Size = .medium
        ) -> EchoScoreDisplay {
            EchoScoreDisplay(score: score, category: category, size: size)
        }
        
        /// Portal loading indicator
        static var portalLoading: PortalLoadingView {
            PortalLoadingView()
        }
        
        /// Insight pill/tag component
        static func insightPill(
            _ text: String,
            icon: String? = nil,
            isSelected: Bool = false
        ) -> InsightPill {
            InsightPill(text: text, icon: icon, isSelected: isSelected)
        }
    }
}

// MARK: - Quick Access Extensions

extension View {
    /// Apply Perspective brand styling
    var perspectiveBrand: some View {
        self
            .accentColor(Perspective.colors.deepInsightBlue)
            .preferredColorScheme(.light)
    }
    
    /// Apply Perspective screen layout
    var perspectiveScreen: some View {
        self
            .screenMargins()
            .background(Perspective.colors.Semantic.background)
    }
    
    /// Apply Perspective card styling (backward compatible)
    func perspectiveCard(
        state: DoorwayState = .closed,
        elevation: Int = 1
    ) -> some View {
        Perspective.Components.card(state: state, elevation: elevation) {
            self
        }
    }
}

// MARK: - Theme Provider

class PerspectiveTheme: ObservableObject {
    @Published var currentTheme: ThemeVariant = .light
    
    enum ThemeVariant {
        case light
        case dark
        case autoEnlightenment // Adapts based on user progress
    }
    
    var colors: PerspectiveColors.Type {
        // Future: return different color sets based on theme
        return PerspectiveColors.self
    }
    
    var animations: PerspectiveAnimations.Type {
        return PerspectiveAnimations.self
    }
}

// MARK: - Design System Initialization

struct PerspectiveDesignSystemModifier: ViewModifier {
    @StateObject private var theme = PerspectiveTheme()
    @StateObject private var animationState = PerspectiveAnimationState()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(theme)
            .environmentObject(animationState)
            .perspectiveBrand
    }
}

extension View {
    /// Initialize the Perspective design system for the entire app
    func perspectiveDesignSystem() -> some View {
        self.modifier(PerspectiveDesignSystemModifier())
    }
}

// MARK: - Migration Helpers

struct DesignSystemMigration {
    /// Helper to identify views that need migration
    static func logMaterial3Usage(_ componentName: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        print("⚠️ Material3 component used: \(componentName) at \(file):\(line)")
        print("💡 Consider migrating to Perspective.\(componentName.lowercased())")
        #endif
    }
    
    /// Gradual migration flag
    static var enableGradualMigration: Bool = true
}

// MARK: - Preview Helper

struct PerspectiveDesignSystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Perspective.spacing.lg) {
                // Colors preview
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ColorPreviewCard(name: "Deep Insight", color: Perspective.colors.deepInsightBlue)
                    ColorPreviewCard(name: "Discovery Teal", color: Perspective.colors.discoveryTeal)
                    ColorPreviewCard(name: "Revelation Purple", color: Perspective.colors.revelationPurple)
                    ColorPreviewCard(name: "Achievement Gold", color: Perspective.colors.achievementGold)
                    ColorPreviewCard(name: "Mind Clear", color: Perspective.colors.mindClear)
                    ColorPreviewCard(name: "Shadow Depth", color: Perspective.colors.shadowDepth)
                }
                
                // Typography preview
                VStack(alignment: .leading, spacing: Perspective.spacing.md) {
                    Text("Typography System")
                        .font(Perspective.typography.Headline.large)
                    
                    Text("Display Large - Space Grotesk")
                        .font(Perspective.typography.Display.large)
                    
                    Text("Body Large - Inter Regular")
                        .font(Perspective.typography.Body.large)
                    
                    Text("Echo Score: 85")
                        .font(Perspective.typography.Data.medium)
                        .foregroundColor(Perspective.colors.achievementGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .perspectiveCard()
                
                // Components preview
                VStack(spacing: Perspective.spacing.md) {
                    Text("Brand Components")
                        .font(Perspective.typography.Headline.medium)
                    
                    Perspective.Components.button("Primary Action", icon: "arrow.right") {}
                    
                    Perspective.Components.button("Portal Button", style: .portal) {}
                    
                    Perspective.Components.echoScore(85, category: .cognitive)
                    
                    HStack {
                        Perspective.Components.insightPill("Growth Mindset", icon: "brain")
                        Perspective.Components.insightPill("Selected", isSelected: true)
                    }
                }
                .perspectiveCard(state: .lightSeeping)
            }
            .perspectivePadding()
        }
        .perspectiveScreen
        .perspectiveDesignSystem()
    }
}

struct ColorPreviewCard: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(Perspective.spacing.sm)
            
            Text(name)
                .font(Perspective.typography.Caption.medium)
                .foregroundColor(Perspective.colors.focusGray)
        }
    }
}

#Preview {
    PerspectiveDesignSystemPreview()
}