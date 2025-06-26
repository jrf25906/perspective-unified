// CardBackgroundModifier.swift
import SwiftUI

public struct CardBackground: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.85))
                    .shadow(radius: 18)
            )
    }
}

public extension View {
    func cardBackground() -> some View {
        self.modifier(CardBackground())
    }
}
