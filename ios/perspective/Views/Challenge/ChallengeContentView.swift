import SwiftUI

struct ChallengeContentView: View {
    let challenge: Challenge
    let onSubmit: (Any) -> Void
    
    @State private var selectedAnswer: String = ""
    @State private var textAnswer: String = ""
    @State private var showingSubmitConfirmation = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Challenge type and difficulty indicator
            ChallengeHeaderView(challenge: challenge)
            
            // Challenge content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(challenge.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(challenge.description)
                        .font(.body)
                        .lineSpacing(4)
                    
                    if let context = challenge.content.context {
                        Text(context)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Type-specific content
                    switch challenge.type {
                    case .multipleChoice, .trueFalse:
                        if let options = challenge.content.options {
                            AnswerOptionsView(
                                options: options,
                                selectedAnswer: $selectedAnswer
                            )
                        }
                        
                    case .shortAnswer, .essay:
                        Text(challenge.content.question)
                            .font(.body)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        FreeTextAnswerView(answer: $textAnswer)
                        
                    case .matching, .ranking:
                        Text(challenge.content.question)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        if let options = challenge.content.options {
                            AnswerOptionsView(
                                options: options,
                                selectedAnswer: $selectedAnswer
                            )
                        }
                        
                    case .scenario:
                        Text(challenge.content.question)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        if let sources = challenge.content.sources {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reference Sources:")
                                    .font(.headline)
                                ForEach(sources, id: \.title) { source in
                                    Text("• \(source.title)")
                                        .font(.callout)
                                        .padding(.leading)
                                }
                            }
                        }
                        
                        FreeTextAnswerView(answer: $textAnswer)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Submit button
            SubmitButton(
                isEnabled: isAnswerValid,
                onSubmit: handleSubmit
            )
        }
    }
    
    private var isAnswerValid: Bool {
        switch challenge.type {
        case .multipleChoice, .trueFalse, .matching, .ranking:
            return !selectedAnswer.isEmpty
        case .shortAnswer, .essay, .scenario:
            return !textAnswer.isEmpty && textAnswer.split(separator: " ").count >= 10 // Minimum word count
        }
    }
    
    private func handleSubmit() {
        let answer: Any
        
        switch challenge.type {
        case .multipleChoice, .trueFalse, .matching, .ranking:
            answer = selectedAnswer
        case .shortAnswer, .essay, .scenario:
            answer = textAnswer
        }
        
        onSubmit(answer)
    }
}

// MARK: - Supporting Views

struct ChallengeHeaderView: View {
    let challenge: Challenge
    
    var typeIcon: String {
        switch challenge.type {
        case .multipleChoice:
            return "list.bullet"
        case .trueFalse:
            return "checkmark.circle"
        case .shortAnswer:
            return "text.quote"
        case .essay:
            return "doc.text"
        case .matching:
            return "arrow.left.arrow.right"
        case .ranking:
            return "list.number"
        case .scenario:
            return "person.2"
        }
    }
    
    var difficultyLevel: Int {
        switch challenge.difficulty {
        case .beginner:
            return 1
        case .intermediate:
            return 2
        case .advanced:
            return 3
        case .expert:
            return 4
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: typeIcon)
                .foregroundColor(.blue)
            Text(challenge.type.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Difficulty indicator
            HStack(spacing: 2) {
                ForEach(1...4, id: \.self) { level in
                    Circle()
                        .fill(level <= difficultyLevel ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Time estimate
            if let timeLimit = challenge.timeLimit {
                Label("\(timeLimit / 60) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Removed unused views that referenced non-existent model properties

struct SubmitButton: View {
    let isEnabled: Bool
    let onSubmit: () -> Void
    @State private var showingConfirmation = false
    
    var body: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            Text("Submit Answer")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .confirmationDialog(
            "Submit your answer?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Submit") {
                onSubmit()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You won't be able to change your answer after submitting.")
        }
    }
}

// MARK: - Common Input Views

struct AnswerOptionsView: View {
    let options: [ChallengeOption]
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                Button(action: {
                    selectedAnswer = option.id
                }) {
                    HStack {
                        Text(option.text)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedAnswer == option.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        selectedAnswer == option.id
                            ? Color.blue.opacity(0.1)
                            : Color(.systemGray6)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedAnswer == option.id ? Color.blue : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct FreeTextAnswerView: View {
    @Binding var answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Response")
                .font(.headline)
                .fontWeight(.medium)
            
            TextEditor(text: $answer)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("\(answer.split(separator: " ").count) words")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                     y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
} 