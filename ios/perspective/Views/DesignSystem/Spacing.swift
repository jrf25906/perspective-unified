import SwiftUI
import UIKit

// MARK: - Perspective Spacing System
// Consistent spacing values based on the doorway metaphor and visual harmony

struct PerspectiveSpacing {
    
    // MARK: - Base Unit
    /// Base spacing unit (4pt) - all other values are multiples of this
    private static let baseUnit: CGFloat = 4
    
    // MARK: - Core Spacing Values
    
    /// 0pt - No spacing
    static let none: CGFloat = 0
    
    /// 2pt - Micro spacing for tight layouts
    static let micro: CGFloat = baseUnit * 0.5
    
    /// 4pt - Extra small spacing for compact elements
    static let xs: CGFloat = baseUnit * 1
    
    /// 8pt - Small spacing for related elements
    static let sm: CGFloat = baseUnit * 2
    
    /// 12pt - Medium-small spacing
    static let md_sm: CGFloat = baseUnit * 3
    
    /// 16pt - Medium spacing for standard layouts
    static let md: CGFloat = baseUnit * 4
    
    /// 20pt - Medium-large spacing
    static let md_lg: CGFloat = baseUnit * 5
    
    /// 24pt - Large spacing for sections
    static let lg: CGFloat = baseUnit * 6
    
    /// 32pt - Extra large spacing for major sections
    static let xl: CGFloat = baseUnit * 8
    
    /// 40pt - 2X large spacing
    static let xxl: CGFloat = baseUnit * 10
    
    /// 48pt - 3X large spacing for major breaks
    static let xxxl: CGFloat = baseUnit * 12
    
    /// 64pt - 4X large spacing for hero sections
    static let xxxxl: CGFloat = baseUnit * 16
    
    // MARK: - Doorway-Specific Spacing
    
    struct Doorway {
        /// Spacing between doorway frame and content
        static let frameInset: CGFloat = baseUnit * 4
        
        /// Spacing for doorway card padding
        static let cardPadding: CGFloat = baseUnit * 5
        
        /// Spacing between multiple doorways
        static let betweenDoorways: CGFloat = baseUnit * 6
        
        /// Margin around doorway groups
        static let groupMargin: CGFloat = baseUnit * 8
        
        /// Spacing for portal transition effects
        static let portalOffset: CGFloat = baseUnit * 10
    }
    
    // MARK: - Component-Specific Spacing
    
    struct Components {
        /// Button internal padding
        static let buttonPaddingHorizontal: CGFloat = baseUnit * 6
        static let buttonPaddingVertical: CGFloat = baseUnit * 3
        
        /// Card internal padding
        static let cardPadding: CGFloat = baseUnit * 4
        
        /// List item spacing
        static let listItemSpacing: CGFloat = baseUnit * 2
        static let listSectionSpacing: CGFloat = baseUnit * 6
        
        /// Form field spacing
        static let formFieldSpacing: CGFloat = baseUnit * 4
        static let formSectionSpacing: CGFloat = baseUnit * 8
        
        /// Navigation spacing
        static let navigationBarPadding: CGFloat = baseUnit * 4
        static let tabBarPadding: CGFloat = baseUnit * 2
    }
    
    // MARK: - Layout Margins
    
    struct Layout {
        /// Standard screen edge margins
        static let screenMargin: CGFloat = baseUnit * 4
        
        /// Comfortable reading margins
        static let readingMargin: CGFloat = baseUnit * 6
        
        /// Wide margins for focus
        static let wideMargin: CGFloat = baseUnit * 8
        
        /// Maximum content width for readability
        static let maxContentWidth: CGFloat = 680
        
        /// Safe area additional padding
        static let safeAreaPadding: CGFloat = baseUnit * 2
    }
    
    // MARK: - Grid System
    
    struct Grid {
        /// Standard grid gap
        static let gap: CGFloat = baseUnit * 4
        
        /// Compact grid gap
        static let compactGap: CGFloat = baseUnit * 2
        
        /// Wide grid gap
        static let wideGap: CGFloat = baseUnit * 6
        
        /// Number of columns for different screen sizes
        static let columnsPhone = 4
        static let columnsTablet = 8
        static let columnsDesktop = 12
    }
    
    // MARK: - Dynamic Spacing
    
    /// Returns spacing that adapts to screen size
    static func adaptive(
        compact: CGFloat,
        regular: CGFloat,
        accessibilitySize: CGFloat? = nil
    ) -> CGFloat {
        let sizeCategory = UIApplication.shared.preferredContentSizeCategory
        
        if let accessibilitySize = accessibilitySize,
           sizeCategory.isAccessibilityCategory {
            return accessibilitySize
        }
        
        // This would be enhanced with actual screen size detection
        let isCompact = UIScreen.main.bounds.width < 375
        return isCompact ? compact : regular
    }
}

// MARK: - Spacing View Modifiers

extension View {
    /// Apply consistent padding using Perspective spacing
    func perspectivePadding(_ edges: Edge.Set = .all, _ size: CGFloat = PerspectiveSpacing.md) -> some View {
        self.padding(edges, size)
    }
    
    /// Apply doorway-style card padding
    func doorwayCardPadding() -> some View {
        self.padding(PerspectiveSpacing.Doorway.cardPadding)
    }
    
    /// Apply standard screen margins
    func screenMargins() -> some View {
        self.padding(.horizontal, PerspectiveSpacing.Layout.screenMargin)
    }
    
    /// Apply reading-optimized margins
    func readingMargins() -> some View {
        self
            .padding(.horizontal, PerspectiveSpacing.Layout.readingMargin)
            .frame(maxWidth: PerspectiveSpacing.Layout.maxContentWidth)
    }
}

// MARK: - Spacer Helpers

extension Spacer {
    /// Fixed-height spacer using Perspective spacing
    static func fixed(_ size: CGFloat) -> some View {
        Color.clear
            .frame(height: size)
    }
    
    /// Fixed-width spacer using Perspective spacing
    static func fixedWidth(_ size: CGFloat) -> some View {
        Color.clear
            .frame(width: size)
    }
}

// MARK: - Stack Spacing Extensions
// Note: Custom VStack/HStack initializers removed to avoid conflicts with SwiftUI
// Use PerspectiveSpacing constants directly in VStack/HStack initializers instead

// MARK: - Layout Guides

struct PerspectiveLayoutGuide {
    /// Returns appropriate spacing for the current size class
    static func spacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        switch sizeClass {
        case .compact:
            return PerspectiveSpacing.sm
        case .regular:
            return PerspectiveSpacing.md
        case .none:
            return PerspectiveSpacing.md
        @unknown default:
            return PerspectiveSpacing.md
        }
    }
    
    /// Returns appropriate margins for the current size class
    static func margins(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        switch sizeClass {
        case .compact:
            return PerspectiveSpacing.Layout.screenMargin
        case .regular:
            return PerspectiveSpacing.Layout.wideMargin
        case .none:
            return PerspectiveSpacing.Layout.screenMargin
        @unknown default:
            return PerspectiveSpacing.Layout.screenMargin
        }
    }
}