import SwiftUI

// MARK: - Perspective Typography System
// Based on the brand framework's three-tier typography approach

struct PerspectiveTypography {
    
    // MARK: - Font Families
    
    private static let primaryFontName = "Inter"
    private static let displayFontName = "SpaceGrotesk"
    private static let monoFontName = "JetBrainsMono"
    
    // MARK: - Font Helpers
    
    private static func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(primaryFontName, size: size).weight(weight)
    }
    
    private static func displayFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(displayFontName, size: size).weight(weight)
    }
    
    private static func monoFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(monoFontName, size: size).weight(weight)
    }
    
    // MARK: - Display Styles (Space Grotesk)
    
    struct Display {
        /// Extra large display text for major headlines
        static let xxLarge = displayFont(size: 72, weight: .bold)
        
        /// Large display text for section headers
        static let xLarge = displayFont(size: 56, weight: .bold)
        
        /// Display text for primary headlines
        static let large = displayFont(size: 48, weight: .semibold)
        
        /// Medium display text for sub-headlines
        static let medium = displayFont(size: 36, weight: .semibold)
        
        /// Small display text for feature titles
        static let small = displayFont(size: 28, weight: .medium)
    }
    
    // MARK: - Headline Styles (Inter)
    
    struct Headline {
        /// Large headline for page titles
        static let large = primaryFont(size: 24, weight: .semibold)
        
        /// Medium headline for section titles
        static let medium = primaryFont(size: 20, weight: .semibold)
        
        /// Small headline for subsection titles
        static let small = primaryFont(size: 18, weight: .semibold)
    }
    
    // MARK: - Title Styles (Inter)
    
    struct Title {
        /// Large title for important content headers
        static let large = primaryFont(size: 22, weight: .medium)
        
        /// Medium title for content headers
        static let medium = primaryFont(size: 18, weight: .medium)
        
        /// Small title for minor headers
        static let small = primaryFont(size: 16, weight: .medium)
    }
    
    // MARK: - Body Styles (Inter)
    
    struct Body {
        /// Large body text for primary content
        static let large = primaryFont(size: 17, weight: .regular)
        
        /// Medium body text for standard content
        static let medium = primaryFont(size: 15, weight: .regular)
        
        /// Small body text for secondary content
        static let small = primaryFont(size: 13, weight: .regular)
    }
    
    // MARK: - Label Styles (Inter)
    
    struct Label {
        /// Large label for buttons and important UI elements
        static let large = primaryFont(size: 16, weight: .medium)
        
        /// Medium label for standard UI elements
        static let medium = primaryFont(size: 14, weight: .medium)
        
        /// Small label for minor UI elements
        static let small = primaryFont(size: 12, weight: .medium)
    }
    
    // MARK: - Caption Styles (Inter)
    
    struct Caption {
        /// Large caption for important metadata
        static let large = primaryFont(size: 13, weight: .regular)
        
        /// Medium caption for standard metadata
        static let medium = primaryFont(size: 12, weight: .regular)
        
        /// Small caption for minor metadata
        static let small = primaryFont(size: 11, weight: .regular)
    }
    
    // MARK: - Data Styles (JetBrains Mono)
    
    struct Data {
        /// Extra large data display for hero metrics
        static let xxLarge = monoFont(size: 64, weight: .bold)
        
        /// Large data display for primary metrics
        static let xLarge = monoFont(size: 48, weight: .semibold)
        
        /// Large data for Echo Scores
        static let large = monoFont(size: 32, weight: .medium)
        
        /// Medium data for statistics
        static let medium = monoFont(size: 20, weight: .medium)
        
        /// Small data for compact metrics
        static let small = monoFont(size: 16, weight: .regular)
        
        /// Inline data for text integration
        static let inline = monoFont(size: 15, weight: .medium)
    }
}

// MARK: - Text Style Modifiers

struct PerspectiveTextStyle: ViewModifier {
    enum Style {
        // Display styles
        case displayXXLarge
        case displayXLarge
        case displayLarge
        case displayMedium
        case displaySmall
        
        // Headline styles
        case headlineLarge
        case headlineMedium
        case headlineSmall
        
        // Title styles
        case titleLarge
        case titleMedium
        case titleSmall
        
        // Body styles
        case bodyLarge
        case bodyMedium
        case bodySmall
        
        // Label styles
        case labelLarge
        case labelMedium
        case labelSmall
        
        // Caption styles
        case captionLarge
        case captionMedium
        case captionSmall
        
        // Data styles
        case dataXXLarge
        case dataXLarge
        case dataLarge
        case dataMedium
        case dataSmall
        case dataInline
    }
    
    let style: Style
    
    func body(content: Content) -> some View {
        content
            .font(fontForStyle)
            .tracking(trackingForStyle)
            .lineSpacing(lineSpacingForStyle)
    }
    
    private var fontForStyle: Font {
        switch style {
        case .displayXXLarge: return PerspectiveTypography.Display.xxLarge
        case .displayXLarge: return PerspectiveTypography.Display.xLarge
        case .displayLarge: return PerspectiveTypography.Display.large
        case .displayMedium: return PerspectiveTypography.Display.medium
        case .displaySmall: return PerspectiveTypography.Display.small
        case .headlineLarge: return PerspectiveTypography.Headline.large
        case .headlineMedium: return PerspectiveTypography.Headline.medium
        case .headlineSmall: return PerspectiveTypography.Headline.small
        case .titleLarge: return PerspectiveTypography.Title.large
        case .titleMedium: return PerspectiveTypography.Title.medium
        case .titleSmall: return PerspectiveTypography.Title.small
        case .bodyLarge: return PerspectiveTypography.Body.large
        case .bodyMedium: return PerspectiveTypography.Body.medium
        case .bodySmall: return PerspectiveTypography.Body.small
        case .labelLarge: return PerspectiveTypography.Label.large
        case .labelMedium: return PerspectiveTypography.Label.medium
        case .labelSmall: return PerspectiveTypography.Label.small
        case .captionLarge: return PerspectiveTypography.Caption.large
        case .captionMedium: return PerspectiveTypography.Caption.medium
        case .captionSmall: return PerspectiveTypography.Caption.small
        case .dataXXLarge: return PerspectiveTypography.Data.xxLarge
        case .dataXLarge: return PerspectiveTypography.Data.xLarge
        case .dataLarge: return PerspectiveTypography.Data.large
        case .dataMedium: return PerspectiveTypography.Data.medium
        case .dataSmall: return PerspectiveTypography.Data.small
        case .dataInline: return PerspectiveTypography.Data.inline
        }
    }
    
    private var trackingForStyle: CGFloat {
        switch style {
        case .displayXXLarge, .displayXLarge: return -1.5
        case .displayLarge, .displayMedium: return -1.0
        case .displaySmall: return -0.5
        case .headlineLarge, .headlineMedium, .headlineSmall: return -0.2
        case .dataXXLarge, .dataXLarge: return 2.0
        case .dataLarge, .dataMedium: return 1.0
        case .dataSmall, .dataInline: return 0.5
        default: return 0
        }
    }
    
    private var lineSpacingForStyle: CGFloat {
        switch style {
        case .displayXXLarge, .displayXLarge, .displayLarge: return 8
        case .displayMedium, .displaySmall: return 6
        case .bodyLarge, .bodyMedium, .bodySmall: return 4
        default: return 2
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply Perspective typography style
    func perspectiveStyle(_ style: PerspectiveTextStyle.Style) -> some View {
        self.modifier(PerspectiveTextStyle(style: style))
    }
}

// MARK: - Text Extensions for Common Patterns

extension Text {
    /// Style for Echo Score display
    func echoScoreStyle(size: PerspectiveTextStyle.Style = .dataLarge) -> some View {
        self
            .perspectiveStyle(size)
            .foregroundColor(PerspectiveColors.achievementGold)
            .shadow(color: PerspectiveColors.achievementGold.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    /// Style for doorway titles
    func doorwayTitleStyle() -> some View {
        self
            .perspectiveStyle(.displaySmall)
            .foregroundColor(PerspectiveColors.discoveryTeal)
            .multilineTextAlignment(.center)
    }
    
    /// Style for insight text
    func insightStyle() -> some View {
        self
            .perspectiveStyle(.bodyLarge)
            .foregroundColor(PerspectiveColors.deepInsightBlue)
            .italic()
    }
    
    /// Style for achievement text
    func achievementStyle() -> some View {
        self
            .perspectiveStyle(.titleLarge)
            .foregroundColor(PerspectiveColors.achievementGold)
            .bold()
    }
}

// MARK: - Fallback Font Registration

struct FontRegistration {
    static func registerCustomFonts() {
        // This would be called in the app's initialization
        // to register custom fonts if they're bundled with the app
        let fonts = [
            "Inter-Regular",
            "Inter-Medium",
            "Inter-SemiBold",
            "Inter-Bold",
            "SpaceGrotesk-Regular",
            "SpaceGrotesk-Medium",
            "SpaceGrotesk-SemiBold",
            "SpaceGrotesk-Bold",
            "JetBrainsMono-Regular",
            "JetBrainsMono-Medium",
            "JetBrainsMono-SemiBold",
            "JetBrainsMono-Bold"
        ]
        
        for fontName in fonts {
            // Font registration logic would go here
            // This is a placeholder for the actual implementation
        }
    }
}