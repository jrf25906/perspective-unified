# Perspective App UI Component Map

This document provides a comprehensive overview of all UI components, views, and design patterns used in the Perspective iOS app. This serves as a reference guide for creating the Play app design.

## Design System

### Material 3 Design System (`Material3DesignSystem.swift`)
The app implements a Material 3 design system with the following components:

#### Colors
- **Primary**: Blue, OnPrimary: White
- **Secondary**: Purple, OnSecondary: White  
- **Tertiary**: Orange, OnTertiary: White
- **Error**: Red, Success: Green
- **Surface**: White, SurfaceVariant: Light gray
- **Outline**: Gray shades for borders

#### Typography
- **Display**: Large Title, Title, Title2 (Regular weight)
- **Headline**: Title2, Headline, Subheadline (Semibold)
- **Title**: Title3, Headline, Subheadline (Medium)
- **Body**: Body, Callout, Footnote
- **Label**: Subheadline, Caption, Caption2 (Medium)

#### Spacing
- None: 0, ExtraSmall: 4, Small: 8, Medium: 16
- Large: 24, ExtraLarge: 32, XXLarge: 48, XXXLarge: 64

#### Corner Radius
- None: 0, Small: 8, Medium: 12, Large: 16, ExtraLarge: 24, Full: 50

#### Elevation (Shadow)
- Levels 0-5 with increasing shadow radius and opacity

### Custom Styles
- **Material3ButtonStyle**: Filled, Tonal, Outlined, Text variations
- **Material3CardStyle**: Cards with elevation/shadow
- **Material3TextFieldStyle**: Styled text inputs
- **CardBackground**: White semi-transparent background with corner radius 28

## Core Views

### Navigation Structure

#### MainTabView
- Tab Bar Navigation with 4 tabs:
  1. **Challenge** (brain.head.profile icon)
  2. **Echo Score** (chart.line.uptrend.xyaxis icon)
  3. **Profile** (person.crop.circle icon)
  4. **Debug** (wrench.and.screwdriver icon)
- Uses filled/unfilled SF Symbols for selected state
- Blue accent color

### Authentication Views

#### WelcomeView
- Full-screen video background (`VideoBackgroundView`)
- Delayed "Continue" button animation
- Black semi-transparent button with white text

#### LoginView
- Email TextField (rounded border style)
- Password SecureField
- Error message display
- "Sign In" button (blue background, white text)
- "OR" divider with horizontal lines
- "Continue with Google" button (white with gray border)
- Loading states with ProgressView

#### RegisterView
- Similar structure to LoginView
- Additional fields for registration

### Challenge Views

#### DailyChallengeView
- Gradient background (blue to purple, diagonal)
- NavigationView with large title
- Refresh button in toolbar
- Conditional content display:
  - Loading state: `ChallengeLoadingView`
  - Error state: `ChallengeErrorView`
  - Completed state: `ChallengeCompletedView`
  - Active state: `ChallengeContentView`

#### DailyChallengeHeaderView
- Displays streak and score information

#### ChallengeContentView
- Challenge presentation and interaction

#### ChallengeCompletedView
- Results display after challenge completion

#### CelebrationView
- Success/achievement animations

### Echo Score Views

#### EchoScoreDashboardView
- NavigationView with ScrollView
- Pull-to-refresh functionality
- Refresh toolbar button
- Sections:
  1. Current Echo Score display
  2. Score breakdown
  3. Progress chart
  4. Insights and recommendations

#### CurrentEchoScoreView
- Large score display
- Visual representation of current score

#### EchoScoreBreakdownView
- Detailed breakdown of score components

#### EchoScoreChartView
- Chart visualization using SwiftUI Charts
- Historical score data display

#### EchoScoreInsightsView
- Personalized insights and recommendations

### Profile Views

#### ProfileView
- NavigationView with ScrollView
- Gear icon for settings
- Sections:
  1. Profile header with edit button
  2. Stats grid (2 columns)
  3. Streak card with visualization
  4. Achievements grid (3 columns)
  5. Settings section

#### ProfileHeaderView
- User avatar, name, and basic info
- Edit profile button

#### ProfileStatsGridView
- LazyVGrid with stat cards
- Stats: Echo Score, Streak, Challenges, Accuracy

#### StreakCardView
- Flame icon with streak count
- Circular day indicators
- Overflow indicator for long streaks

#### AchievementsSection
- 3-column grid of achievement badges
- Earned/unearned states

#### SettingsSection
- List-style settings rows
- Icons, titles, and chevron indicators

### Reusable Components

#### SyncStatusIndicator
- Network status display
- Three variants:
  1. **Standard**: Button with icon and status text
  2. **Compact**: Simple dot with count
  3. **Banner**: Full-width notification banner
- States: Connected, Offline, Syncing
- Colors: Green (synced), Red (pending), Gray (offline)

#### SyncStatusDetailView
- Modal sheet with detailed sync information
- Sections: Connection, Synchronization, Cached Data, Actions
- Manual sync button when applicable

#### VideoBackgroundView
- UIViewRepresentable for video playback
- Fallback gradient background
- Auto-loop functionality
- Muted playback

#### StatCard
- Icon, value, title layout
- Colored icon based on stat type
- Card background modifier

#### AchievementBadge
- Circular icon container
- Title below icon
- Earned/unearned visual states

#### SettingsRow
- Icon, title, optional chevron
- Horizontal layout with padding
- Tap gesture support

## Design Patterns

### View Modifiers
- `.cardBackground()`: White semi-transparent rounded rectangle
- `.material3Card(elevation:)`: Material Design card style
- `.material3Button(type:)`: Material Design button styles
- `.material3TextField()`: Material Design text field

### Color Usage
- Primary actions: Blue
- Success states: Green
- Error states: Red
- Neutral/disabled: Gray
- Accent: Purple, Orange
- Backgrounds: White with opacity

### Typography Hierarchy
- Navigation titles: Large title display mode
- Section headers: Headline with semibold
- Body text: Body font
- Supporting text: Caption/footnote in secondary color
- Values/stats: Title font with bold

### Layout Patterns
- Standard padding: 20px horizontal, varied vertical
- Card spacing: 16-24px between sections
- Grid layouts: 2-3 columns for compact items
- List layouts: Full-width rows with dividers

### Animation Patterns
- Loading states: ProgressView with scale effect
- Transitions: Opacity combined with movement
- Button presses: Scale effect (0.95) with opacity
- Network indicators: Rotation animation for syncing

### State Management
- @StateObject for view models
- @EnvironmentObject for APIService
- @State for local view state
- @Published for observable properties
- Combine framework for reactive updates

## Navigation Patterns
- Tab-based main navigation
- Modal sheets for editing/details
- NavigationView with large titles
- Toolbar items for actions
- Pull-to-refresh on scrollable content

This comprehensive map provides a complete overview of the Perspective app's UI architecture and can be used as a reference when designing the Play app.