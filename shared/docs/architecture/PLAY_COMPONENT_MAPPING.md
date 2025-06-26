# Play to Swift Component Mapping Guide

## Overview
This document maps each existing Swift component in the Perspective app to its corresponding Play app design approach, ensuring consistency between design and code.

## Component Mapping Table

### 1. Authentication Components

| Swift Component | Location | Play Design Approach | Key Properties |
|-----------------|----------|---------------------|----------------|
| **WelcomeView** | `/Views/WelcomeView.swift` | Full-screen with video background layer | - Video background<br>- Logo (120x120)<br>- Two CTA buttons<br>- Title + subtitle |
| **LoginView** | `/Views/Authentication/LoginView.swift` | Standard iOS form layout | - Email field<br>- Password field (secure)<br>- Sign In button<br>- Social login options<br>- "Forgot Password" link |
| **RegisterView** | `/Views/Authentication/RegisterView.swift` | Multi-field form with validation | - Name field<br>- Email field<br>- Password field<br>- Confirm password<br>- Terms checkbox |

### 2. Challenge Components

| Swift Component | Location | Play Design Approach | Key Properties |
|-----------------|----------|---------------------|----------------|
| **DailyChallengeView** | `/Views/Challenge/DailyChallengeView.swift` | State-based container view | States: loading, error, empty, active, completed |
| **ChallengeContentView** | `/Views/Challenge/ChallengeContentView.swift` | Dynamic content area | - Question text<br>- Answer options<br>- Submit button<br>- Progress indicator |
| **ChallengeLoadingView** | `/Views/Challenge/ChallengeLoadingView.swift` | Skeleton screen | - Animated placeholders<br>- Consistent with content layout |
| **ChallengeCompletedView** | `/Views/Challenge/ChallengeCompletedView.swift` | Result display with actions | - Score display<br>- Feedback text<br>- "Next Challenge" CTA |

### 3. Echo Score Components

| Swift Component | Location | Play Design Approach | Key Properties |
|-----------------|----------|---------------------|----------------|
| **EchoScoreDashboardView** | `/Views/EchoScore/EchoScoreDashboardView.swift` | Dashboard layout with cards | - Score gauge (0-100)<br>- Trend indicator<br>- Component breakdown<br>- Quick stats |
| **CurrentEchoScoreView** | `/Views/EchoScore/CurrentEchoScoreView.swift` | Circular progress indicator | - Large score display<br>- Animated progress ring<br>- Color-coded status |
| **EchoScoreBreakdownView** | `/Views/EchoScore/EchoScoreBreakdownView.swift` | Horizontal bar chart | - 5 components<br>- Color-coded bars<br>- Score labels |

### 4. Profile Components

| Swift Component | Location | Play Design Approach | Key Properties |
|-----------------|----------|---------------------|----------------|
| **ProfileView** | `/Views/Profile/ProfileView.swift` | Scrollable sections layout | - Header with avatar<br>- Stats section<br>- Quick actions<br>- Settings link |
| **ProfileHeaderView** | `/Views/Profile/ProfileHeaderView.swift` | Hero-style header | - 80x80 avatar<br>- Name & username<br>- Edit button overlay |
| **ProfileStatisticsView** | `/Views/Profile/ProfileStatisticsView.swift` | Grid of stat cards | - 2-column grid<br>- Icon + value + label<br>- Consistent card styling |

### 5. Reusable Components

| Swift Component | Play Component Type | Design Specifications |
|-----------------|-------------------|---------------------|
| **Material3.Card** | Card Component | - 12pt corner radius<br>- White background<br>- Subtle shadow (elevation 2)<br>- 16pt padding |
| **Material3.Button** | Button Variants | - Primary: Blue fill, white text<br>- Secondary: Blue tint background<br>- Text: No background, blue text<br>- Height: 44pt |
| **SyncStatusIndicator** | Status Component | - 3 variants: standard, compact, banner<br>- Icon + text<br>- Color-coded states |
| **StatCard** | Data Display Card | - Icon (24x24)<br>- Large value text<br>- Subtitle label<br>- Tap action |

## Design Token Mapping

### Colors (Material3 → Play)

```swift
// Swift Code                    // Play Color Name
Material3.Colors.primary         → primary (#007AFF)
Material3.Colors.onPrimary      → onPrimary (#FFFFFF)
Material3.Colors.surface        → surface (#FFFFFF)
Material3.Colors.error          → error (#FF3B30)
Material3.Colors.success        → success (#34C759)
```

### Typography (Material3 → Play)

```swift
// Swift Code                    // Play Text Style
Material3.Typography.displayLarge → Display Large (57pt)
Material3.Typography.headlineMedium → Headline Medium (28pt)
Material3.Typography.bodyLarge   → Body Large (16pt)
Material3.Typography.labelMedium → Label Medium (12pt)
```

### Spacing (Material3 → Play)

```swift
// Swift Code                    // Play Spacing
Material3.Spacing.small         → small (8pt)
Material3.Spacing.medium        → medium (16pt)
Material3.Spacing.large         → large (24pt)
```

## Component State Mapping

### Button States
- **Default**: Base color, enabled
- **Pressed**: 0.98 scale, darker shade
- **Disabled**: 0.5 opacity
- **Loading**: Show progress indicator

### Input Field States
- **Default**: Gray border (#E5E5EA)
- **Focused**: Blue border (#007AFF)
- **Error**: Red border (#FF3B30)
- **Disabled**: 0.5 opacity

### Card States
- **Default**: Elevation 2 shadow
- **Pressed**: Elevation 4 shadow
- **Disabled**: 0.5 opacity, no interaction

## Layout Patterns in Play

### 1. List Layouts
```
VStack(spacing: 16) {
    // Components
}
```
→ Use Play's Stack with 16pt spacing

### 2. Grid Layouts
```
LazyVGrid(columns: 2)
```
→ Use Play's Grid with 2 columns, 16pt gap

### 3. Navigation Patterns
- Tab Bar: Use iOS Tab Bar component
- Navigation Bar: Large title style
- Modal Sheets: Full-screen or form sheets

## Animation Specifications

| Animation Type | Duration | Easing |
|---------------|----------|---------|
| View Transitions | 0.3s | Ease In Out |
| Button Press | 0.1s | Ease Out |
| Loading States | Continuous | Linear |
| Score Updates | 0.5s | Spring |

## Export Checklist for Play → Swift

1. **Colors**: Export as Color Set (.colorset)
2. **Icons**: SF Symbols names or custom SVGs
3. **Spacing**: Point values (not pixels)
4. **Typography**: Font names and sizes
5. **Components**: SwiftUI code snippets
6. **Animations**: Timing and easing functions

## Best Practices for Play Design

1. **Use Native iOS Components**: Leverage Play's iOS components
2. **Maintain Consistency**: Follow the Material3 design system
3. **Design for All States**: Include loading, error, empty states
4. **Consider Accessibility**: Test with Dynamic Type
5. **Preview on Device**: Use Play's iOS preview feature

## Quick Reference Commands

### In Swift Code
```swift
// Button
Material3.button(style: .primary) { }

// Card
.modifier(Material3.cardBackground())

// Colors
Material3.Colors.primary
```

### In Play App
- Create "Material3 Button" component with variants
- Apply "Card Background" style
- Use color token "primary"

This mapping ensures your Play designs will translate seamlessly to the existing Swift codebase.