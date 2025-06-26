import SwiftUI
import Combine

struct DailyChallengeView: View {
    @StateObject private var viewModel = DailyChallengeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient matching brand
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with streak and score
                        DailyChallengeHeaderView()
                        
                        // Main challenge content
                        if viewModel.isLoading {
                            ChallengeLoadingView()
                        } else if let challenge = viewModel.currentChallenge {
                            if viewModel.isCompleted {
                                ChallengeCompletedView(
                                    challenge: challenge,
                                    result: viewModel.challengeResult
                                )
                            } else {
                                ChallengeContentView(
                                    challenge: challenge,
                                    onSubmit: viewModel.submitChallenge
                                )
                            }
                        } else if let error = viewModel.errorMessage {
                            ChallengeErrorView(error: error) {
                                viewModel.loadTodayChallenge()
                            }
                            .onAppear {
                                // Log detailed error info when error view appears
                                print("❌ Challenge Error View displayed")
                                print("❌ Error message: \(error)")
                                
                                // Check if it's a decoding error
                                if error.lowercased().contains("decode") || error.lowercased().contains("failed to decode") {
                                    print("❌ This appears to be a decoding error")
                                    print("❌ Common causes:")
                                    print("   1. Backend response doesn't match iOS Challenge model")
                                    print("   2. Date format issues")
                                    print("   3. Missing required fields")
                                    print("   4. Type mismatches")
                                    print("❌ Check Xcode console for detailed NetworkClient logs")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Daily Challenge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadTodayChallenge()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

// Note: DailyChallengeViewModel is now centralized in ViewModels/DailyChallengeViewModel.swift
// This follows proper MVVM architecture with dependency injection 