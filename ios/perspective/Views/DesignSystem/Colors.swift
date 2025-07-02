import SwiftUI
import Foundation

// MARK: - Perspective Brand Colors
// Based on the "Enlightenment Spectrum" from the brand framework

struct PerspectiveColors {
    
    // MARK: - Enlightenment Spectrum Primary Colors
    
    /// Deep Insight Blue (#1E3A8A) - Trust, wisdom, depth
    static let deepInsightBlue = Color(hex: "1E3A8A")
    
    /// Discovery Teal (#0891B2) - Growth, exploration, clarity
    static let discoveryTeal = Color(hex: "0891B2")
    
    /// Revelation Purple (#7C3AED) - Transformation, insight, possibility
    static let revelationPurple = Color(hex: "7C3AED")
    
    /// Achievement Gold (#F59E0B) - Success, reward, accomplishment
    static let achievementGold = Color(hex: "F59E0B")
    
    // MARK: - Cognitive Neutrals
    
    /// Mind Clear (#F8FAFC) - Clean thinking, clarity
    static let mindClear = Color(hex: "F8FAFC")
    
    /// Focus Gray (#64748B) - Concentration, balance
    static let focusGray = Color(hex: "64748B")
    
    /// Shadow Depth (#1E293B) - Depth, complexity
    static let shadowDepth = Color(hex: "1E293B")
    
    // MARK: - Semantic Colors
    
    struct Semantic {
        // Primary actions and navigation
        static let primary = deepInsightBlue
        static let primaryContainer = deepInsightBlue.opacity(0.12)
        static let onPrimary = mindClear
        static let onPrimaryContainer = deepInsightBlue
        
        // Secondary actions and accents
        static let secondary = discoveryTeal
        static let secondaryContainer = discoveryTeal.opacity(0.12)
        static let onSecondary = mindClear
        static let onSecondaryContainer = discoveryTeal
        
        // Tertiary actions and highlights
        static let tertiary = revelationPurple
        static let tertiaryContainer = revelationPurple.opacity(0.12)
        static let onTertiary = mindClear
        static let onTertiaryContainer = revelationPurple
        
        // Success states and achievements
        static let success = achievementGold
        static let successContainer = achievementGold.opacity(0.12)
        static let onSuccess = shadowDepth
        static let onSuccessContainer = achievementGold
        
        // Error states
        static let error = Color(hex: "DC2626")
        static let errorContainer = Color(hex: "DC2626").opacity(0.12)
        static let onError = mindClear
        static let onErrorContainer = Color(hex: "DC2626")
        
        // Surface colors
        static let surface = mindClear
        static let surfaceVariant = Color(hex: "F1F5F9")
        static let onSurface = shadowDepth
        static let onSurfaceVariant = focusGray
        
        // Background colors
        static let background = Color(hex: "FAFBFC")
        static let onBackground = shadowDepth
        
        // Outline colors
        static let outline = focusGray.opacity(0.5)
        static let outlineVariant = focusGray.opacity(0.25)
        
        // Inverse colors
        static let inverseSurface = shadowDepth
        static let inverseOnSurface = mindClear
        static let inversePrimary = discoveryTeal
    }
    
    // MARK: - Doorway State Colors
    // Colors representing different states of the doorway metaphor
    
    struct DoorwayStates {
        /// Closed door - challenge not yet attempted
        static let closed = shadowDepth
        
        /// Light seeping through - in progress
        static let lightSeeping = LinearGradient(
            colors: [achievementGold.opacity(0.3), discoveryTeal.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Opening door - discovering new perspective
        static let opening = LinearGradient(
            colors: [discoveryTeal, revelationPurple],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        /// Fully open - enlightenment achieved
        static let enlightened = LinearGradient(
            colors: [achievementGold, revelationPurple, deepInsightBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Echo Score Colors
    
    struct EchoScore {
        static let cognitive = deepInsightBlue
        static let social = discoveryTeal
        static let practical = achievementGold
        static let creative = revelationPurple
        static let analytical = focusGray
    }
    
    // MARK: - Gradient Definitions
    
    struct Gradients {
        /// Main brand gradient representing the journey of perspective
        static let enlightenmentSpectrum = LinearGradient(
            colors: [deepInsightBlue, discoveryTeal, revelationPurple, achievementGold],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Subtle background gradient
        static let subtleBackground = LinearGradient(
            colors: [mindClear, Color(hex: "F0F9FF")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        /// Portal effect gradient
        static let portal = RadialGradient(
            colors: [
                discoveryTeal.opacity(0.8),
                revelationPurple.opacity(0.6),
                deepInsightBlue.opacity(0.4),
                Color.clear
            ],
            center: .center,
            startRadius: 5,
            endRadius: 200
        )
        
        /// Achievement burst gradient
        static let achievementBurst = RadialGradient(
            colors: [
                achievementGold,
                achievementGold.opacity(0.6),
                achievementGold.opacity(0.3),
                Color.clear
            ],
            center: .center,
            startRadius: 10,
            endRadius: 150
        )
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Apply the main brand gradient as a background
    func enlightenmentBackground() -> some View {
        self.background(PerspectiveColors.Gradients.enlightenmentSpectrum)
    }
    
    /// Apply a subtle portal effect background
    func portalBackground() -> some View {
        self.background(PerspectiveColors.Gradients.portal)
    }
    
    /// Apply doorway state styling
    func doorwayState(_ state: DoorwayState) -> some View {
        self.modifier(DoorwayStateModifier(state: state))
    }
}

// MARK: - Doorway State Enum

enum DoorwayState: CaseIterable, Hashable {
    case closed
    case lightSeeping
    case opening
    case enlightened
}

// MARK: - Doorway State Modifier

struct DoorwayStateModifier: ViewModifier {
    let state: DoorwayState
    
    func body(content: Content) -> some View {
        content
            .background(backgroundForState)
            .foregroundColor(foregroundForState)
    }
    
    private var backgroundForState: some View {
        Group {
            switch state {
            case .closed:
                Color(PerspectiveColors.DoorwayStates.closed)
            case .lightSeeping:
                PerspectiveColors.DoorwayStates.lightSeeping
            case .opening:
                PerspectiveColors.DoorwayStates.opening
            case .enlightened:
                PerspectiveColors.DoorwayStates.enlightened
            }
        }
    }
    
    private var foregroundForState: Color {
        switch state {
        case .closed:
            return PerspectiveColors.mindClear
        case .lightSeeping, .opening, .enlightened:
            return PerspectiveColors.shadowDepth
        }
    }
}