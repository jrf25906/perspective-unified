# iOS Design Patterns for Perspective App

## iOS-Specific UI Considerations

### Screen Sizes to Design For
```
iPhone Models (Points):
- iPhone 15 Pro Max: 430 × 932
- iPhone 15/14/13: 390 × 844
- iPhone 15/14/13 Pro: 393 × 852
- iPhone SE: 375 × 667
- iPhone 15/14 Plus: 428 × 926

Safe Areas:
- Top: 59pt (Dynamic Island) or 47pt (Notch) or 20pt (SE)
- Bottom: 34pt (Home Indicator) or 0pt (Home Button)
```

### iOS Navigation Patterns

#### Tab Bar Navigation (Current Implementation)
The app correctly uses a tab bar for main navigation:

```swift
// SwiftUI Implementation
TabView(selection: $selectedTab) {
    DailyChallengeView()
        .tabItem {
            Image(systemName: "brain.head.profile")
            Text("Challenge")
        }
        .tag(0)
    // ... other tabs
}
```

### Navigation Bar Patterns
```
Standard Navigation Bar:
- Height: 44pt (standard) + status bar
- Large Title: Scrolls with content
- Bar Button Items: Left (back) and right (actions)
- Search: Can be embedded when needed
```

### iOS Design Guidelines

#### Status Bar
```
- Always visible (except in full-screen media)
- Adapts to content (light/dark)
- Consider Dynamic Island on newer devices
```

#### Tab Bar Specifications
```
- Height: 49pt (83pt with safe area on newer devices)
- Icons: 25×25pt (max 48×32pt)
- Always visible during main navigation
- 2-5 items recommended
- Badge support for notifications
```

#### Navigation Hierarchy
```
1. Tab Bar (Main sections)
2. Navigation Stack (Within each tab)
3. Modal Presentations (For focused tasks)
4. Action Sheets (For options)
```

### iOS-Specific Components

#### 1. Pull to Refresh
```swift
.refreshable {
    await viewModel.refresh()
}
```

#### 2. Swipe Actions
For list items:
```
- Leading: Custom actions
- Trailing: Delete, archive, etc.
- Full swipe for primary action
```

#### 3. Haptic Feedback
Strategic use of haptics:
- Success: .success
- Warning: .warning
- Error: .error
- Selection: .selection
- Impact: .light, .medium, .heavy

### iOS Gesture Patterns
```
Essential Gestures:
- Tap: Primary selection
- Long Press: Context menu
- Swipe Left/Right: Actions on list items
- Swipe Down: Pull to refresh
- Pinch: Zoom (on charts/images)
- Pan: Scroll and dismiss modals
- 3D Touch/Haptic Touch: Quick actions
```

### Dark Mode Support
```swift
// Automatic dark mode switching
@Environment(\.colorScheme) var colorScheme

// iOS System Colors that adapt automatically
Color(.systemBackground)
Color(.secondarySystemBackground)
Color(.label)
Color(.secondaryLabel)
```

### iOS Animations
```
Native iOS Feel:
- View transitions: 0.3s with spring
- List insertions: 0.25s ease-out
- Tab switches: Instant with subtle fade
- Modal presentations: 0.35s cover vertical
- Loading states: Activity indicator
```

### Data Visualization
For Echo Score charts on iOS:
- Use Charts framework (iOS 16+)
- Touch-friendly interactions
- Clear contrast for outdoor viewing
- Smooth 60fps animations
- Accessible color schemes

### Typography for iOS
```
Dynamic Type Support:
- Use system text styles
- Support all accessibility sizes
- Test with larger text sizes
- Maintain readability at all sizes
```

### Touch Targets
```
Minimum sizes:
- Buttons: 44×44pt
- List rows: 44pt height minimum
- Tab bar items: Full tab width
- Interactive elements: 44×44pt
```

### iOS Presentation Styles
```swift
// Sheet (bottom modal)
.sheet(isPresented: $showingSheet) {
    SheetView()
}

// Full screen cover
.fullScreenCover(isPresented: $showingFullScreen) {
    FullScreenView()
}

// Popover (iPad)
.popover(isPresented: $showingPopover) {
    PopoverContent()
}
```

### Performance Optimizations
```
- LazyVStack/LazyHStack for lists
- Image caching with AsyncImage
- Background tasks with Task
- 60fps scrolling performance
- Memory management for images
```

### Accessibility
```
VoiceOver Support:
- All elements properly labeled
- Traits correctly assigned
- Custom actions for complex views
- Dynamic Type support
- Sufficient color contrast
```

### iOS System Integration
1. **Share Sheet**: Share results and achievements
2. **Widgets**: Daily challenge widget
3. **Shortcuts**: Siri shortcuts for quick actions
4. **Notifications**: Local notifications for streaks
5. **Face ID/Touch ID**: Secure authentication

### SwiftUI iOS App Structure
```swift
@main
struct PerspectiveApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.userPreferredColorScheme)
        }
    }
}
```

### iOS Design Resources

#### Play App Setup Tips
1. **Import iOS UI Kit**: Use iOS 17 components
2. **Set up iPhone frames**: Multiple device sizes
3. **Use SF Symbols**: For all system icons
4. **Apply iOS spacing**: 8pt grid system
5. **Test with notch/Dynamic Island**: Safe area considerations

#### Component Libraries for Play
- iOS 17 Design System
- SF Symbols 5
- Apple Design Resources
- iOS Navigation Patterns
- Mobile Gesture Library

This guide ensures your Perspective app follows iOS Human Interface Guidelines while maintaining excellent user experience. 