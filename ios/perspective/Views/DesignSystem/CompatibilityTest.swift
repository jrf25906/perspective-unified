import SwiftUI

// MARK: - Design System Compatibility Test
// Ensures Material3 components still work with new Perspective design system

struct CompatibilityTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Material3.Spacing.large) {
                Text("Compatibility Test")
                    .font(Material3.Typography.headlineLarge)
                    .foregroundColor(Material3.Colors.primary)
                
                // Test Material3 buttons still work
                VStack(spacing: Material3.Spacing.medium) {
                    Text("Material3 Components (Legacy)")
                        .font(Material3.Typography.titleMedium)
                    
                    Button("Material3 Filled Button") {}
                        .material3Button(.filled)
                    
                    Button("Material3 Outlined Button") {}
                        .material3Button(.outlined)
                }
                .material3Card()
                .padding(Material3.Spacing.medium)
                
                // Test new Perspective components
                VStack(spacing: Perspective.spacing.md) {
                    Text("Perspective Components (New)")
                        .perspectiveStyle(.titleMedium)
                    
                    Perspective.Components.button("Perspective Primary") {}
                    
                    Perspective.Components.button("Perspective Portal", style: .portal) {}
                    
                    Perspective.Components.echoScore(85, category: .cognitive)
                }
                .perspectiveCard(state: .lightSeeping)
                
                // Test color compatibility
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                    ColorTestCard(title: "Legacy Primary", color: Material3.Colors.primary)
                    ColorTestCard(title: "New Primary", color: Perspective.colors.deepInsightBlue)
                    ColorTestCard(title: "Legacy Secondary", color: Material3.Colors.secondary)
                    ColorTestCard(title: "New Secondary", color: Perspective.colors.discoveryTeal)
                }
                .padding(Material3.Spacing.medium)
                
                // Test typography compatibility
                VStack(alignment: .leading, spacing: Perspective.spacing.sm) {
                    Text("Typography Compatibility")
                        .font(Material3.Typography.titleLarge)
                    
                    Text("Material3 Body Large")
                        .font(Material3.Typography.bodyLarge)
                    
                    Text("Perspective Body Large")
                        .perspectiveStyle(.bodyLarge)
                    
                    Text("Material3 Label Medium")
                        .font(Material3.Typography.labelMedium)
                    
                    Text("Perspective Label Medium")
                        .perspectiveStyle(.labelMedium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .material3Card()
                .padding(Material3.Spacing.medium)
            }
        }
        .perspectiveDesignSystem()
        .background(Perspective.colors.Semantic.background)
    }
}

struct ColorTestCard: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 40)
                .cornerRadius(8)
            
            Text(title)
                .font(Material3.Typography.labelSmall)
                .foregroundColor(Material3.Colors.onSurface)
        }
    }
}

// MARK: - Compatibility Verification

struct DesignSystemCompatibility {
    /// Verify that Material3 colors map correctly to Perspective colors
    static func verifyColorMapping() -> Bool {
        let tests = [
            Material3.Colors.primary == Perspective.colors.deepInsightBlue,
            Material3.Colors.secondary == Perspective.colors.discoveryTeal,
            Material3.Colors.tertiary == Perspective.colors.revelationPurple,
            Material3.Colors.success == Perspective.colors.achievementGold
        ]
        
        let success = tests.allSatisfy { $0 }
        print("🧪 Color mapping compatibility: \(success ? "✅ PASS" : "❌ FAIL")")
        return success
    }
    
    /// Verify that spacing values are consistent
    static func verifySpacingMapping() -> Bool {
        let tests = [
            Material3.Spacing.small == Perspective.spacing.sm,
            Material3.Spacing.medium == Perspective.spacing.md,
            Material3.Spacing.large == Perspective.spacing.lg
        ]
        
        let success = tests.allSatisfy { $0 }
        print("🧪 Spacing mapping compatibility: \(success ? "✅ PASS" : "❌ FAIL")")
        return success
    }
    
    /// Run all compatibility tests
    static func runAllTests() -> Bool {
        print("🧪 Running Design System Compatibility Tests...")
        
        let colorTest = verifyColorMapping()
        let spacingTest = verifySpacingMapping()
        
        let allTestsPass = colorTest && spacingTest
        print("🧪 Overall compatibility: \(allTestsPass ? "✅ ALL TESTS PASS" : "❌ SOME TESTS FAILED")")
        
        return allTestsPass
    }
}

// MARK: - Migration Helper View

struct MigrationHelperView: View {
    @State private var showMaterial3 = true
    
    var body: some View {
        VStack(spacing: Perspective.spacing.lg) {
            Text("Design System Migration")
                .perspectiveStyle(.displayMedium)
            
            Toggle("Show Material3 Style", isOn: $showMaterial3)
                .padding()
            
            if showMaterial3 {
                // Old style
                VStack {
                    Text("Material3 Style")
                        .font(Material3.Typography.titleLarge)
                        .foregroundColor(Material3.Colors.primary)
                    
                    Button("Old Button") {}
                        .material3Button(.filled)
                }
                .material3Card()
                .padding()
            } else {
                // New style
                VStack {
                    Text("Perspective Style")
                        .perspectiveStyle(.titleLarge)
                        .foregroundColor(Perspective.colors.deepInsightBlue)
                    
                    Perspective.Components.button("New Button") {}
                }
                .perspectiveCard(state: .lightSeeping)
            }
        }
        .perspectiveDesignSystem()
        .onAppear {
            DesignSystemCompatibility.runAllTests()
        }
    }
}

#Preview("Compatibility Test") {
    CompatibilityTestView()
}

#Preview("Migration Helper") {
    MigrationHelperView()
}