import SwiftUI

// MARK: - Perspective Animation System
// Based on the "Every interaction is a doorway opening" philosophy

struct PerspectiveAnimations {
    
    // MARK: - Timing Curves
    
    struct TimingCurves {
        /// Smooth ease for general transitions
        static let smooth = Animation.easeInOut
        
        /// Spring animation for responsive interactions
        static let responsive = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
        
        /// Gentle spring for subtle movements
        static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0)
        
        /// Bouncy spring for playful elements
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
        
        /// Snappy animation for quick state changes
        static let snappy = Animation.easeOut
        
        /// Portal opening curve - starts slow, speeds up, then eases
        static let portal = Animation.timingCurve(0.25, 0.1, 0.25, 1.0)
        
        /// Enlightenment curve - gradual reveal
        static let enlightenment = Animation.timingCurve(0.4, 0.0, 0.2, 1.0)
    }
    
    // MARK: - Durations
    
    struct Durations {
        /// Micro interaction (0.1s)
        static let micro: Double = 0.1
        
        /// Quick interaction (0.3s)
        static let quick: Double = 0.3
        
        /// Standard interaction (0.5s)
        static let standard: Double = 0.5
        
        /// Perspective shift (0.8s)
        static let perspectiveShift: Double = 0.8
        
        /// Major transition (1.2s)
        static let majorTransition: Double = 1.2
        
        /// Portal opening (1.5s)
        static let portalOpening: Double = 1.5
        
        /// Achievement celebration (2.0s)
        static let achievement: Double = 2.0
    }
    
    // MARK: - Predefined Animations
    
    /// Button tap animation
    static let buttonTap = TimingCurves.responsive.speed(3)
    
    /// Card appearance animation
    static let cardAppear = TimingCurves.gentle.delay(0.1)
    
    /// Doorway opening animation
    static let doorwayOpen = TimingCurves.portal.speed(1.0 / Durations.portalOpening)
    
    /// Light seeping effect
    static let lightSeep = TimingCurves.enlightenment.speed(1.0 / Durations.majorTransition)
    
    /// Echo score update
    static let scoreUpdate = TimingCurves.bouncy.speed(1.0 / Durations.standard)
    
    /// View transition
    static let viewTransition = TimingCurves.smooth.speed(1.0 / Durations.perspectiveShift)
    
    /// Achievement burst
    static let achievementBurst = TimingCurves.bouncy.speed(1.0 / Durations.achievement)
    
    // MARK: - Sequence Helpers
    
    /// Creates a staggered animation for list items
    static func staggered(index: Int, count: Int, baseAnimation: Animation = cardAppear) -> Animation {
        let delay = Double(index) * 0.05
        let dampening = 1.0 - (Double(index) / Double(count) * 0.3)
        return baseAnimation.delay(delay).speed(dampening)
    }
    
    /// Creates a ripple effect animation
    static func ripple(from center: CGPoint, index: Int) -> Animation {
        let delay = Double(index) * 0.02
        return TimingCurves.gentle.delay(delay)
    }
}

// MARK: - Animation View Modifiers

struct DoorwayTransition: ViewModifier {
    let isOpen: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isOpen ? 1 : 0.9)
            .opacity(isOpen ? 1 : 0)
            .rotation3DEffect(
                .degrees(isOpen ? 0 : 10),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(PerspectiveAnimations.doorwayOpen, value: isOpen)
    }
}

struct LightSeepingEffect: ViewModifier {
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: PerspectiveSpacing.Doorway.frameInset)
                    .stroke(
                        LinearGradient(
                            colors: [
                                PerspectiveColors.achievementGold.opacity(intensity * 0.6),
                                PerspectiveColors.discoveryTeal.opacity(intensity * 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 4)
                    .animation(PerspectiveAnimations.lightSeep, value: intensity)
            )
    }
}

struct EnlightenmentBurst: ViewModifier {
    let isActive: Bool
    @State private var animationPhase = 0.0
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(PerspectiveColors.achievementGold.opacity(0.3))
                            .frame(width: 100, height: 140)
                            .rotationEffect(.degrees(Double(index) * 60))
                            .scaleEffect(isActive ? 1.5 : 0.1)
                            .opacity(isActive ? 0 : 1)
                            .animation(
                                PerspectiveAnimations.achievementBurst
                                    .delay(Double(index) * 0.1),
                                value: isActive
                            )
                    }
                }
            )
    }
}

struct PortalFlipTransition: ViewModifier {
    let isFlipped: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(abs((isFlipped ? 180 : 0) - 90) / 90)
            .animation(PerspectiveAnimations.viewTransition, value: isFlipped)
    }
}

struct FloatingAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    let amplitude: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    offset = amplitude
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply doorway opening transition
    func doorwayTransition(isOpen: Bool) -> some View {
        self.modifier(DoorwayTransition(isOpen: isOpen))
    }
    
    /// Apply light seeping effect
    func lightSeeping(intensity: Double) -> some View {
        self.modifier(LightSeepingEffect(intensity: intensity))
    }
    
    /// Apply enlightenment burst effect
    func enlightenmentBurst(isActive: Bool) -> some View {
        self.modifier(EnlightenmentBurst(isActive: isActive))
    }
    
    /// Apply portal flip transition
    func portalFlip(isFlipped: Bool) -> some View {
        self.modifier(PortalFlipTransition(isFlipped: isFlipped))
    }
    
    /// Apply floating animation
    func floating(amplitude: CGFloat = 10, duration: Double = 2) -> some View {
        self.modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
    
    /// Apply a perspective shift animation
    func perspectiveShift() -> some View {
        self.transition(
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        )
    }
}

// MARK: - Custom Transitions

extension AnyTransition {
    /// Doorway-style transition
    static var doorway: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
    
    /// Portal-style transition
    static var portal: AnyTransition {
        .modifier(
            active: PortalTransitionModifier(progress: 0),
            identity: PortalTransitionModifier(progress: 1)
        )
    }
}

struct PortalTransitionModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(progress)
            .opacity(progress)
            .blur(radius: (1 - progress) * 10)
            .brightness(progress * 0.2)
    }
}

// MARK: - Animation State Manager

class PerspectiveAnimationState: ObservableObject {
    @Published var doorwayStates: [String: Bool] = [:]
    @Published var enlightenmentProgress: [String: Double] = [:]
    
    func openDoorway(_ id: String) {
        withAnimation(PerspectiveAnimations.doorwayOpen) {
            doorwayStates[id] = true
        }
    }
    
    func closeDoorway(_ id: String) {
        withAnimation(PerspectiveAnimations.doorwayOpen) {
            doorwayStates[id] = false
        }
    }
    
    func updateEnlightenment(_ id: String, progress: Double) {
        withAnimation(PerspectiveAnimations.lightSeep) {
            enlightenmentProgress[id] = progress
        }
    }
}