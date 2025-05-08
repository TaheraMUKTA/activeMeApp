//
//  HydrationSummaryView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 26/03/2025.
//

import SwiftUI

struct HydrationSummaryView: View {
    @ObservedObject var hydrationViewModel: HydrationViewModel

    // Calculate hydration progress (0 to 1)
    var progress: Double {
        let goal = hydrationViewModel.dailyWaterGoal
        guard goal > 0 else { return 0 }
        return min((hydrationViewModel.currentWaterIntake / goal).clamped(to: 0...1), 1.0)
    }

    // Calculate how many bottles are left to reach the goal
    var bottlesRemaining: Int {
        let remaining = hydrationViewModel.dailyWaterGoal - hydrationViewModel.currentWaterIntake
        return max(Int(floor(remaining)), 0)
    }

    // Dynamic message based on user's progress
    var statusMessage: String {
            if bottlesRemaining <= 0 {
                return "Goal Reached!"
            } else if bottlesRemaining == 1 {
                return "Almost there! 1 Bottle left"
            } else {
                return "\(bottlesRemaining) Bottles to go"
            }
        }

    // Change drop color when goal is reached
    var dropColor: Color {
        bottlesRemaining <= 0 ? .green : .blue
    }

    var body: some View {
        HStack {
            // Info text section
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Water Intake")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .transition(.opacity.combined(with: .slide))
                    .id(statusMessage)    // Helps with smooth animation
            }

            Spacer()

            // Drop shape filled according to progress
            ZStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .frame(width: 50, height: 60)
                    .foregroundColor(.white.opacity(0.8))
                
                Image(systemName: "drop.fill")
                    .resizable()
                    .frame(width: 46, height: 56)
                    .foregroundColor(Color.blue)
                    .mask(
                        VStack {
                            Spacer(minLength: 0)
                            Rectangle()
                                .frame(height: CGFloat(60 * progress))    // Fill based on progress
                        }
                        
                    )
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.6))
        .cornerRadius(15)
        .shadow(radius: 3)
        .animation(.spring(), value: bottlesRemaining)
    }
}

#Preview {
    HydrationSummaryView(hydrationViewModel: HydrationViewModel())
}

// Clamp helper to keep values within range
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
