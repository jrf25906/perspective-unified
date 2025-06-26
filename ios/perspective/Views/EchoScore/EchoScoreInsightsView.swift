import SwiftUI

struct EchoScoreInsightsView: View {
    let score: EchoScore
    
    private var insights: [Insight] {
        var insights: [Insight] = []
        
        // Analyze each component and provide insights based on scoreBreakdown
        if score.scoreBreakdown.mediaLiteracy < 50 {
            insights.append(Insight(
                type: .improvement,
                title: "Enhance Media Literacy",
                description: "Try analyzing news sources from different outlets to improve your media literacy skills.",
                icon: "newspaper",
                color: .blue
            ))
        }
        
        if score.scoreBreakdown.politicalAwareness < 60 {
            insights.append(Insight(
                type: .improvement,
                title: "Broaden Political Understanding",
                description: "Explore diverse political viewpoints to enhance your awareness.",
                icon: "building.columns",
                color: .green
            ))
        }
        
        if score.scoreBreakdown.cognitiveReflection < 70 {
            insights.append(Insight(
                type: .improvement,
                title: "Strengthen Critical Thinking",
                description: "Take time to reflect deeply on challenges before answering.",
                icon: "brain",
                color: .orange
            ))
        }
        
        if score.scoreBreakdown.sourceEvaluation < 60 {
            insights.append(Insight(
                type: .improvement,
                title: "Improve Source Evaluation",
                description: "Practice verifying information credibility and sources.",
                icon: "checkmark.shield",
                color: .purple
            ))
        }
        
        if score.scoreBreakdown.biasRecognition < 50 {
            insights.append(Insight(
                type: .improvement,
                title: "Develop Bias Recognition",
                description: "Work on identifying biases in yourself and information sources.",
                icon: "eye.trianglebadge.exclamationmark",
                color: .pink
            ))
        }
        
        // Add insights from the actual insights property
        for insight in score.insights {
            insights.append(Insight(
                type: insight.type == .strength ? .strength : .improvement,
                title: insight.title,
                description: insight.description,
                icon: getIconForInsightType(insight.type),
                color: getColorForPriority(insight.priority)
            ))
        }
        
        // Add positive reinforcement
        let strongestComponent = getStrongestComponent()
        if insights.filter({ $0.type == .strength }).isEmpty {
            insights.append(Insight(
                type: .strength,
                title: "Your Strength: \(strongestComponent.name)",
                description: strongestComponent.description,
                icon: strongestComponent.icon,
                color: strongestComponent.color
            ))
        }
        
        return insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights & Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(insights) { insight in
                InsightCardView(insight: insight)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private func getStrongestComponent() -> (name: String, description: String, icon: String, color: Color) {
        let components = [
            ("Media Literacy", score.scoreBreakdown.mediaLiteracy, "You excel at understanding media sources.", "newspaper", Color.blue),
            ("Political Awareness", score.scoreBreakdown.politicalAwareness, "Your political knowledge is strong.", "building.columns", Color.green),
            ("Cognitive Reflection", score.scoreBreakdown.cognitiveReflection, "Your critical thinking skills shine.", "brain", Color.orange),
            ("Source Evaluation", score.scoreBreakdown.sourceEvaluation, "You're great at verifying credibility.", "checkmark.shield", Color.purple),
            ("Bias Recognition", score.scoreBreakdown.biasRecognition, "You effectively identify biases.", "eye.trianglebadge.exclamationmark", Color.pink)
        ]
        
        let strongest = components.max { $0.1 < $1.1 } ?? components[0]
        return (strongest.0, strongest.2, strongest.3, strongest.4)
    }
    
    private func getIconForInsightType(_ type: ScoreInsight.InsightType) -> String {
        switch type {
        case .strength:
            return "star.fill"
        case .weakness:
            return "exclamationmark.triangle"
        case .opportunity:
            return "lightbulb"
        case .trend:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    private func getColorForPriority(_ priority: ScoreInsight.InsightPriority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .yellow
        }
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    enum InsightType {
        case improvement
        case strength
        case warning
    }
}

struct InsightCardView: View {
    let insight: Insight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundColor(insight.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            if insight.type == .strength {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(insight.color.opacity(0.1))
        .cornerRadius(12)
    }
} 