import SwiftUI

// MARK: - Material 3 Design System (Bridged to Perspective Brand)
// This maintains Material3 API compatibility while using Perspective brand colors
// Existing code using Material3 components will automatically get the new brand styling

struct Material3 {
    
    // MARK: - Colors
    // Updated to use Perspective brand colors while maintaining Material3 API
    struct Colors {
        // Primary colors - now using Perspective Deep Insight Blue
        static let primary = PerspectiveColors.deepInsightBlue
        static let primaryContainer = PerspectiveColors.Semantic.primaryContainer
        static let onPrimary = PerspectiveColors.Semantic.onPrimary
        static let onPrimaryContainer = PerspectiveColors.Semantic.onPrimaryContainer
        
        // Secondary colors - now using Perspective Discovery Teal
        static let secondary = PerspectiveColors.discoveryTeal
        static let secondaryContainer = PerspectiveColors.Semantic.secondaryContainer
        static let onSecondary = PerspectiveColors.Semantic.onSecondary
        static let onSecondaryContainer = PerspectiveColors.Semantic.onSecondaryContainer
        
        // Tertiary colors - now using Perspective Revelation Purple
        static let tertiary = PerspectiveColors.revelationPurple
        static let tertiaryContainer = PerspectiveColors.Semantic.tertiaryContainer
        static let onTertiary = PerspectiveColors.Semantic.onTertiary
        static let onTertiaryContainer = PerspectiveColors.Semantic.onTertiaryContainer
        
        // Error colors - using Perspective semantic colors
        static let error = PerspectiveColors.Semantic.error
        static let errorContainer = PerspectiveColors.Semantic.errorContainer
        static let onError = PerspectiveColors.Semantic.onError
        static let onErrorContainer = PerspectiveColors.Semantic.onErrorContainer
        
        // Success colors - now using Perspective Achievement Gold
        static let success = PerspectiveColors.achievementGold
        static let successContainer = PerspectiveColors.Semantic.successContainer
        static let onSuccess = PerspectiveColors.Semantic.onSuccess
        static let onSuccessContainer = PerspectiveColors.Semantic.onSuccessContainer
        
        // Surface colors - using Perspective semantic colors
        static let surface = PerspectiveColors.Semantic.surface
        static let surfaceVariant = PerspectiveColors.Semantic.surfaceVariant
        static let onSurface = PerspectiveColors.Semantic.onSurface
        static let onSurfaceVariant = PerspectiveColors.Semantic.onSurfaceVariant
        
        // Outline colors - using Perspective semantic colors
        static let outline = PerspectiveColors.Semantic.outline
        static let outlineVariant = PerspectiveColors.Semantic.outlineVariant
        
        // Inverse colors - using Perspective semantic colors
        static let inverseSurface = PerspectiveColors.Semantic.inverseSurface
        static let inverseOnSurface = PerspectiveColors.Semantic.inverseOnSurface
        static let inversePrimary = PerspectiveColors.Semantic.inversePrimary
    }
    
    // MARK: - Typography
    struct Typography {
        // Display styles
        static let displayLarge = Font.largeTitle.weight(.regular)
        static let displayMedium = Font.title.weight(.regular)
        static let displaySmall = Font.title2.weight(.regular)
        
        // Headline styles
        static let headlineLarge = Font.title2.weight(.semibold)
        static let headlineMedium = Font.headline.weight(.semibold)
        static let headlineSmall = Font.subheadline.weight(.semibold)
        
        // Title styles
        static let titleLarge = Font.title3.weight(.medium)
        static let titleMedium = Font.headline.weight(.medium)
        static let titleSmall = Font.subheadline.weight(.medium)
        
        // Body styles
        static let bodyLarge = Font.body
        static let bodyMedium = Font.callout
        static let bodySmall = Font.footnote
        
        // Label styles
        static let labelLarge = Font.subheadline.weight(.medium)
        static let labelMedium = Font.caption.weight(.medium)
        static let labelSmall = Font.caption2.weight(.medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let none: CGFloat = 0
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
        static let xxxLarge: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let none: CGFloat = 0
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let full: CGFloat = 50
    }
    
    // MARK: - Elevation (Shadow)
    struct Elevation {
        static func level(_ level: Int) -> (radius: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) {
            switch level {
            case 0:
                return (0, 0, 0, 0)
            case 1:
                return (1, 0, 1, 0.05)
            case 2:
                return (3, 0, 1, 0.08)
            case 3:
                return (6, 0, 2, 0.10)
            case 4:
                return (8, 0, 4, 0.12)
            case 5:
                return (12, 0, 6, 0.14)
            default:
                return (12, 0, 6, 0.14)
            }
        }
    }
}

// MARK: - Material 3 Component Styles

struct Material3ButtonStyle: ButtonStyle {
    enum ButtonType {
        case filled
        case tonal
        case outlined
        case text
        
        var backgroundColor: Color {
            switch self {
            case .filled:
                return Material3.Colors.primary
            case .tonal:
                return Material3.Colors.primaryContainer
            case .outlined, .text:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .filled:
                return Material3.Colors.onPrimary
            case .tonal:
                return Material3.Colors.onPrimaryContainer
            case .outlined, .text:
                return Material3.Colors.primary
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outlined:
                return 1
            default:
                return 0
            }
        }
    }
    
    let type: ButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Material3.Typography.labelLarge)
            .foregroundColor(type.foregroundColor)
            .padding(.horizontal, Material3.Spacing.large)
            .padding(.vertical, Material3.Spacing.medium)
            .background(type.backgroundColor)
            .cornerRadius(Material3.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: Material3.CornerRadius.large)
                    .stroke(Material3.Colors.outline, lineWidth: type.borderWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct Material3CardStyle: ViewModifier {
    let elevation: Int
    
    func body(content: Content) -> some View {
        let shadow = Material3.Elevation.level(elevation)
        
        content
            .background(Material3.Colors.surface)
            .cornerRadius(Material3.CornerRadius.medium)
            .shadow(
                color: Color.black.opacity(shadow.opacity),
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

struct Material3TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Material3.Typography.bodyLarge)
            .padding(Material3.Spacing.medium)
            .background(Material3.Colors.surfaceVariant)
            .cornerRadius(Material3.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: Material3.CornerRadius.small)
                    .stroke(Material3.Colors.outline, lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func material3Card(elevation: Int = 1) -> some View {
        self.modifier(Material3CardStyle(elevation: elevation))
    }
    
    func material3Button(_ type: Material3ButtonStyle.ButtonType = .filled) -> some View {
        self.buttonStyle(Material3ButtonStyle(type: type))
    }
    
    func material3TextField() -> some View {
        self.modifier(Material3TextFieldModifier())
    }
}

// MARK: - Component Previews

struct Material3DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: Material3.Spacing.large) {
                // Typography examples
                VStack(alignment: .leading, spacing: Material3.Spacing.small) {
                    Text("Typography")
                        .font(Material3.Typography.headlineLarge)
                    
                    Text("Display Large")
                        .font(Material3.Typography.displayLarge)
                    
                    Text("Headline Medium")
                        .font(Material3.Typography.headlineMedium)
                    
                    Text("Body Large - This is the default body text style used throughout the app.")
                        .font(Material3.Typography.bodyLarge)
                    
                    Text("Label Medium")
                        .font(Material3.Typography.labelMedium)
                        .foregroundColor(Material3.Colors.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .material3Card()
                .padding(Material3.Spacing.medium)
                
                // Button examples
                VStack(spacing: Material3.Spacing.medium) {
                    Text("Buttons")
                        .font(Material3.Typography.headlineMedium)
                    
                    Button("Filled Button") {}
                        .material3Button(.filled)
                    
                    Button("Tonal Button") {}
                        .material3Button(.tonal)
                    
                    Button("Outlined Button") {}
                        .material3Button(.outlined)
                    
                    Button("Text Button") {}
                        .material3Button(.text)
                }
                .material3Card(elevation: 2)
                .padding(Material3.Spacing.medium)
                
                // Color examples
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ColorSwatch(name: "Primary", color: Material3.Colors.primary)
                    ColorSwatch(name: "Secondary", color: Material3.Colors.secondary)
                    ColorSwatch(name: "Tertiary", color: Material3.Colors.tertiary)
                    ColorSwatch(name: "Success", color: Material3.Colors.success)
                    ColorSwatch(name: "Error", color: Material3.Colors.error)
                    ColorSwatch(name: "Surface", color: Material3.Colors.surfaceVariant)
                }
                .material3Card()
                .padding(Material3.Spacing.medium)
            }
        }
        .padding(Material3.Spacing.medium)
        .background(Material3.Colors.surface)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(Material3.CornerRadius.small)
            
            Text(name)
                .font(Material3.Typography.labelSmall)
                .foregroundColor(Material3.Colors.onSurfaceVariant)
        }
    }
} 