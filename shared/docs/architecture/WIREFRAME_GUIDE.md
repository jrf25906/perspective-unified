# Perspective App - Detailed Wireframe Guide

## Table of Contents
1. [App Overview](#app-overview)
2. [Design System](#design-system)
3. [Navigation Structure](#navigation-structure)
4. [Page Breakdowns](#page-breakdowns)
5. [Component Library](#component-library)
6. [Asset Requirements](#asset-requirements)
7. [Interactive States](#interactive-states)
8. [Figma Setup Guide](#figma-setup-guide)

---

## App Overview

**Purpose**: A media literacy and perspective-taking app that helps users break out of echo chambers and recognize biases through gamified challenges and tracking.

**Target Platform**: iOS (iPhone and iPad)

**Key Features**:
- Daily challenges for perspective-taking
- Echo Score tracking and analytics
- User profiles with achievements
- Bias assessment tools
- News source analysis

---

## Design System

### Color Palette
```
Primary Colors:
- Primary Blue: #007AFF (System Blue)
- Success Green: #34C759
- Warning Orange: #FF9500
- Error Red: #FF3B30
- Background: #F2F2F7 (Light Mode)
- Surface: #FFFFFF
- Text Primary: #000000
- Text Secondary: #8E8E93

Difficulty Colors:
- Beginner: #34C759 (Green)
- Intermediate: #007AFF (Blue)
- Advanced: #FF9500 (Orange)
- Expert: #FF3B30 (Red)
```

### Typography
```
- Headlines: SF Pro Display (Bold, 28-34pt)
- Titles: SF Pro Display (Semibold, 20-24pt)
- Body: SF Pro Text (Regular, 16pt)
- Caption: SF Pro Text (Regular, 13pt)
- Button Text: SF Pro Text (Medium, 16pt)
```

### Spacing System
```
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px
```

### Corner Radius
```
- Small: 6px (buttons, small cards)
- Medium: 12px (cards, containers)
- Large: 16px (modals, large cards)
```

---

## Navigation Structure

### Main Tab Bar (iOS Bottom Navigation)
- **Position**: Bottom of screen
- **Height**: 49pt (83pt with safe area on Face ID devices)
- **Background**: iOS system background with blur
- **Items**: 4 tabs with icon + label

### Tab Items:
1. **Challenge** (brain.head.profile icon)
2. **Echo Score** (chart.line.uptrend.xyaxis icon)
3. **Profile** (person.crop.circle icon)
4. **Debug** (wrench.and.screwdriver icon) - Development only

---

## Page Breakdowns

### 1. Authentication Flow

#### 1.1 Login Screen
**Components**:
- App logo (centered, 120x120px)
- App name title
- Email input field
- Password input field (with show/hide toggle)
- "Remember Me" checkbox
- "Sign In" button (primary, full-width)
- "Forgot Password?" link
- Divider with "OR"
- "Sign in with Apple" button
- "Sign in with Google" button
- "New user? Sign up" link at bottom

**Layout**: Full-screen with content centered, respecting safe areas

#### 1.2 Sign Up Screen
**Components**:
- Back button (top-left)
- "Create Account" title
- Full name input field
- Email input field
- Password input field (with strength indicator)
- Confirm password field
- Terms & Privacy checkbox with links
- "Create Account" button (primary)
- Social sign-up options
- "Already have an account? Sign in" link

#### 1.3 Password Reset Screen
**Components**:
- Back button
- "Reset Password" title
- Explanatory text
- Email input field
- "Send Reset Link" button
- Success/error message area

---

### 2. Daily Challenge Tab

#### 2.1 Challenge List View (Default)
**Components**:
- Header Section:
  - "Today's Challenge" title
  - Current streak indicator (flame icon + number)
  - XP balance display
- Featured Challenge Card:
  - Challenge title
  - Difficulty badge (color-coded)
  - Estimated time
  - XP reward
  - "Start Challenge" button
  - Expiry timer (if daily)
- Previous Challenges Section:
  - Section title with "View All" link
  - List of 3-5 recent challenge cards (compact view)
- Statistics Widget:
  - Accuracy percentage
  - Challenges completed
  - Current streak

**Layout**: Scrollable vertical list with 24px padding

#### 2.2 Active Challenge View
**Components**:
- Progress Bar (top)
- Timer (if time-limited)
- Challenge Content Area:
  - Question text (large, readable)
  - Context/scenario (if applicable)
  - Media viewer (if images/videos)
- Answer Area (varies by type):
  - Multiple Choice: Radio button list
  - True/False: Two large buttons
  - Short Answer: Text input field
  - Essay: Large text area with word count
  - Matching: Drag-and-drop interface
  - Ranking: Draggable list
  - Scenario: Multiple input areas
- Bottom Action Bar:
  - "Submit" button (primary)
  - "Get Hint" button (costs XP)
  - "Skip" button (secondary)

#### 2.3 Challenge Results View
**Components**:
- Result Header:
  - Success/failure animation
  - Score/XP earned display
  - Streak update notification
- Feedback Section:
  - Correct answer explanation
  - Your answer comparison
  - Detailed feedback
  - Bias indicators (if detected)
- Learning Resources:
  - Related articles/sources
  - "Learn More" links
- Action Buttons:
  - "Next Challenge" (primary)
  - "Share Result" (secondary)
  - "View Stats" (tertiary)

---

### 3. Echo Score Tab

#### 3.1 Echo Score Dashboard
**Components**:
- Score Display Widget:
  - Large circular progress indicator (0-100)
  - Current score in center
  - Trend arrow and percentage change
  - "Last updated" timestamp
- Score Breakdown Chart:
  - Radar/spider chart showing 5 components:
    - Media Literacy
    - Political Awareness
    - Cognitive Reflection
    - Source Evaluation
    - Bias Recognition
  - Each axis labeled with score
- Insights Section:
  - 2-3 insight cards with:
    - Icon (strength/weakness/opportunity)
    - Title
    - Description
    - Recommendation
    - Priority indicator
- Quick Actions:
  - "Take Assessment" button
  - "View History" button

**Layout**: Responsive grid, adapts to window width

#### 3.2 Score History View
**Components**:
- Time Range Selector:
  - Week/Month/Year/All Time tabs
- Line Graph:
  - Score over time
  - Interactive hover states
  - Key events marked
- History List:
  - Date
  - Score
  - Key activities
  - Expandable details

#### 3.3 Insights & Recommendations
**Components**:
- Categorized Insight Cards:
  - Strengths section
  - Areas for improvement
  - Opportunities
- Recommendation Cards:
  - Action title
  - Expected impact
  - "Start" button
  - Difficulty/time estimate

---

### 4. Profile Tab

#### 4.1 User Profile View
**Components**:
- Profile Header:
  - Avatar (editable, 120px)
  - Display name
  - Username
  - Member since date
  - Edit profile button
- Stats Overview:
  - Total XP
  - Current level & progress bar
  - Challenges completed
  - Current streak
  - Accuracy rate
- Achievement Showcase:
  - Recent achievements (3-5)
  - "View All" link
- Activity Feed:
  - Recent activities list
  - Load more button

#### 4.2 Achievements View
**Components**:
- Achievement Categories:
  - Tab bar for categories
  - Progress overview per category
- Achievement Grid:
  - Achievement badges (locked/unlocked)
  - Name and description
  - Progress bars for incomplete
  - Rarity indicators

#### 4.3 Settings View
**Components**:
- Account Settings Section:
  - Profile information
  - Email preferences
  - Password change
- App Preferences:
  - Notification settings
  - Privacy settings
  - Data & sync options
- Support Section:
  - Help center link
  - Contact support
  - About the app
  - Terms & Privacy
- Danger Zone:
  - Sign out button
  - Delete account option

---

## Component Library

### Buttons
1. **Primary Button**
   - Background: Primary blue
   - Text: White, medium weight
   - Height: 44px
   - Corner radius: 6px
   - Hover: Darker shade
   - Active: Even darker + scale(0.98)

2. **Secondary Button**
   - Background: Light gray
   - Text: Primary text color
   - Same dimensions as primary

3. **Text Button**
   - No background
   - Text: Primary blue
   - Underline on hover

### Cards
1. **Challenge Card**
   - White background
   - 12px corner radius
   - Subtle shadow
   - Padding: 16px
   - Hover: Slight elevation change

2. **Insight Card**
   - Icon (32x32)
   - Title (semibold)
   - Description (regular)
   - Optional action button

### Input Fields
1. **Text Input**
   - Height: 44px
   - Border: 1px solid #E5E5EA
   - Corner radius: 6px
   - Padding: 12px
   - Focus: Blue border

2. **Text Area**
   - Min height: 120px
   - Same styling as text input
   - Resize handle

### Progress Indicators
1. **Circular Progress**
   - Customizable size
   - Animated fill
   - Center text/icon

2. **Linear Progress Bar**
   - Height: 8px
   - Rounded ends
   - Animated fill

---

## Asset Requirements

### Icons (SF Symbols preferred)
- Navigation icons (4)
- Challenge type icons (7)
- Difficulty badges (4)
- Achievement badges (20-30)
- UI action icons (15-20)

### Images
- App logo (multiple sizes)
- Onboarding illustrations (3-5)
- Empty state illustrations (3-4)
- Achievement artwork

### Animations
- Success/failure animations
- Loading states
- Transition animations
- Micro-interactions

---

## Interactive States

### Hover States
- Buttons: Color change + cursor pointer
- Cards: Subtle shadow elevation
- Links: Underline or color change

### Active/Pressed States
- Buttons: Scale down slightly (0.98)
- Cards: Deeper shadow

### Loading States
- Skeleton screens for content
- Spinning indicators for actions
- Progress bars for uploads

### Error States
- Red border on invalid inputs
- Error messages below fields
- Toast notifications for system errors

### Empty States
- Friendly illustration
- Explanatory text
- Call-to-action button

---

## Play App Design Setup Guide

### 1. Project Structure
```
Perspective iOS App/
├── 📄 Cover
├── 📁 Design System
│   ├── Colors
│   ├── Typography
│   ├── Icons (SF Symbols)
│   └── Components
├── 📁 Screens
│   ├── Authentication
│   ├── Challenge
│   ├── Echo Score
│   └── Profile
├── 📁 Flows
│   └── [User journey prototypes]
└── 📁 Export
    └── [Developer assets]
```

### 2. Component Setup in Play
1. Import iOS 17 component library
2. Create custom components with variants
3. Use iOS Auto Layout for responsive design
4. Apply Dynamic Type to all text
5. Set up color schemes for light/dark mode

### 3. Prototyping in Play
1. Connect screens with iOS transitions
2. Add native iOS gestures (swipe, tap, long press)
3. Preview on actual iOS devices
4. Test with different device sizes
5. Validate safe area compliance

### 4. iOS Design Tokens
```json
{
  "colors": {
    "primary": "#007AFF",
    "success": "#34C759",
    "warning": "#FF9500",
    "error": "#FF3B30",
    "systemBackground": "adaptive",
    "label": "adaptive"
  },
  "spacing": {
    "xs": "4pt",
    "sm": "8pt",
    "md": "16pt",
    "lg": "24pt"
  },
  "radius": {
    "small": "6pt",
    "medium": "12pt",
    "large": "16pt",
    "continuous": "iOS continuous corners"
  }
}
```

### 5. Developer Handoff from Play
1. Export to SwiftUI code
2. Generate asset catalogs
3. Export design specifications
4. Document gesture interactions
5. Provide animation timings

---

## Next Steps

1. **Set up Figma file** with the structure outlined above
2. **Create design system** with all base components
3. **Design wireframes** for each screen
4. **Build component library** in SwiftUI
5. **Create prototypes** for user testing
6. **Iterate based on feedback**

This guide provides a comprehensive foundation for your UI development. Each section can be expanded as you progress through the design process. 