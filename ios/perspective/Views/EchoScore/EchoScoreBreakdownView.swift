import SwiftUI

public struct EchoScoreBreakdownView: View {
    let score: EchoScore
    
    public init(score: EchoScore) {
        self.score = score
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ScoreComponentView(
                    title: "Media Literacy",
                    score: score.scoreBreakdown.mediaLiteracy,
                    icon: "globe",
                    color: .blue,
                    description: "Understanding of media sources and bias"
                )
                
                ScoreComponentView(
                    title: "Political Awareness",
                    score: score.scoreBreakdown.politicalAwareness,
                    icon: "building.columns",
                    color: .green,
                    description: "Knowledge of political perspectives"
                )
                
                ScoreComponentView(
                    title: "Cognitive Reflection",
                    score: score.scoreBreakdown.cognitiveReflection,
                    icon: "brain",
                    color: .orange,
                    description: "Critical thinking and analysis skills"
                )
                
                ScoreComponentView(
                    title: "Source Evaluation",
                    score: score.scoreBreakdown.sourceEvaluation,
                    icon: "checkmark.shield",
                    color: .purple,
                    description: "Ability to assess information credibility"
                )
                
                ScoreComponentView(
                    title: "Bias Recognition",
                    score: score.scoreBreakdown.biasRecognition,
                    icon: "eye.trianglebadge.exclamationmark",
                    color: .pink,
                    description: "Identifying and accounting for biases"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct ScoreComponentView: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(score))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: max(0, geometry.size.width * (score / 100)), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 8)
    }
} 