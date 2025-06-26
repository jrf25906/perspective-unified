# Play App Project Setup Guide for Perspective

## Initial Project Structure in Play

### 1. Create New Project
- **Project Name**: Perspective iOS
- **Device**: iPhone (with iPad compatibility)
- **Orientation**: Portrait primary, Landscape supported
- **Base Resolution**: iPhone 15 Pro (393×852)

### 2. Page Organization

```
📱 Perspective iOS
├── 🎨 Cover Page
│   └── App branding and overview
├── 📐 Design System
│   ├── Colors & Themes
│   ├── Typography Scale
│   ├── Spacing & Layout
│   ├── Components Library
│   └── Icons (SF Symbols)
├── 📱 Screens
│   ├── 🔐 Authentication
│   │   ├── Login
│   │   ├── Register
│   │   └── Password Reset
│   ├── 🎯 Challenge
│   │   ├── Challenge List
│   │   ├── Active Challenge
│   │   └── Challenge Results
│   ├── 📊 Echo Score
│   │   ├── Dashboard
│   │   ├── Score History
│   │   └── Insights
│   ├── 👤 Profile
│   │   ├── Profile View
│   │   ├── Edit Profile
│   │   ├── Achievements
│   │   └── Settings
│   └── 🔧 Debug (Dev Only)
│       └── API Test View
├── 🔄 User Flows
│   ├── Onboarding Flow
│   ├── Challenge Flow
│   └── Authentication Flow
└── 📤 Export
    ├── Design Tokens
    ├── Component Specs
    └── Assets
```

## Design System Setup in Play

### Step 1: Import Base Resources
1. **iOS 17 UI Kit**: Import from Play's resource library
2. **SF Symbols 5**: Add symbol library for icons
3. **Dynamic Type**: Enable for all text styles

### Step 2: Color System Configuration

Create these color styles in Play to match your Material3 system:

```
Primary Colors:
- primary: #007AFF (iOS Blue)
- primaryContainer: #007AFF @ 10%
- onPrimary: #FFFFFF
- onPrimaryContainer: #007AFF

Secondary Colors:
- secondary: #AF52DE (Purple)
- secondaryContainer: #AF52DE @ 10%
- onSecondary: #FFFFFF
- onSecondaryContainer: #AF52DE

Tertiary Colors:
- tertiary: #FF9500 (Orange)
- tertiaryContainer: #FF9500 @ 10%
- onTertiary: #FFFFFF
- onTertiaryContainer: #FF9500

Semantic Colors:
- error: #FF3B30
- errorContainer: #FF3B30 @ 10%
- success: #34C759
- successContainer: #34C759 @ 10%

Surface Colors:
- surface: #FFFFFF
- surfaceVariant: #F5F5F7
- onSurface: #1A1A1A
- onSurfaceVariant: #666666

System Colors:
- outline: #B3B3B3
- outlineVariant: #CCCCCC
- inverseSurface: #1A1A1A
- inverseOnSurface: #FFFFFF
```

### Step 3: Typography Scale

Set up these text styles:

```
Display (SF Pro Display):
- displayLarge: 57pt, Regular
- displayMedium: 45pt, Regular
- displaySmall: 36pt, Regular

Headlines (SF Pro Display):
- headlineLarge: 32pt, Semibold
- headlineMedium: 28pt, Semibold
- headlineSmall: 24pt, Semibold

Titles (SF Pro Text):
- titleLarge: 22pt, Medium
- titleMedium: 16pt, Medium
- titleSmall: 14pt, Medium

Body (SF Pro Text):
- bodyLarge: 16pt, Regular
- bodyMedium: 14pt, Regular
- bodySmall: 12pt, Regular

Labels (SF Pro Text):
- labelLarge: 14pt, Medium
- labelMedium: 12pt, Medium
- labelSmall: 11pt, Medium
```

### Step 4: Spacing System

Create spacing tokens:
```
- none: 0pt
- extraSmall: 4pt
- small: 8pt
- medium: 16pt
- large: 24pt
- extraLarge: 32pt
- xxLarge: 48pt
- xxxLarge: 64pt
```

### Step 5: Component Setup

Create these base components with proper Auto Layout:

1. **Buttons**
   - Primary Button (filled)
   - Secondary Button (tinted)
   - Text Button (plain)
   - Icon Button

2. **Input Fields**
   - Text Field
   - Password Field
   - Text Area
   - Search Field

3. **Cards**
   - Challenge Card
   - Insight Card
   - Achievement Card
   - Stats Card

4. **Navigation**
   - Tab Bar
   - Navigation Bar
   - Back Button
   - Action Buttons

## Play-Specific Features to Enable

1. **iOS Preview Mode**: Always design with iOS preview on
2. **Safe Areas**: Enable safe area guides
3. **Dynamic Type**: Test with different text sizes
4. **Dark Mode**: Create dark variants for all screens
5. **Device Testing**: Preview on multiple iPhone sizes

## Component States to Design

For each component, create these variants:
- Default
- Hover (for iPadOS)
- Pressed
- Disabled
- Focus
- Error
- Success

## Export Settings

Configure these export options:
1. **Design Tokens**: JSON format
2. **Colors**: iOS Color Set format
3. **Icons**: PDF or SVG
4. **Components**: SwiftUI code snippets
5. **Spacing**: Points (pt) not pixels

## Integration with Existing Code

### Naming Convention
Match your Swift file names:
- `LoginView` → "Login Screen" in Play
- `DailyChallengeView` → "Daily Challenge Screen"
- `ProfileView` → "Profile Screen"

### Component Mapping
- Play Button → SwiftUI Button with Material3 styling
- Play Card → SwiftUI View with Material3.Card modifier
- Play Input → SwiftUI TextField with custom styling

## Next Steps After Setup

1. **Week 1**: Complete Design System page
2. **Week 2**: Design all authentication screens
3. **Week 3**: Create challenge flow screens
4. **Week 4**: Build profile and settings screens

## Tips for Efficiency

1. **Use Components**: Don't duplicate, create reusable components
2. **Master Instances**: Use for consistent updates
3. **Keyboard Shortcuts**: Learn Play's shortcuts for speed
4. **Version Control**: Save versions before major changes
5. **Preview Often**: Constantly check iOS preview

## Figma Integration Workflow

If using Figma:
1. Export Play designs to Figma
2. Create design specs in Figma
3. Share with developers via Figma
4. Import updates back to Play for iterations

Remember: Play excels at iOS-native design, so leverage its SwiftUI export and iOS preview features heavily.