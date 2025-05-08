//
//  HydrationTrackerView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 20/03/2025.
//

import SwiftUI

struct HydrationTrackerView: View {
    @StateObject var hydrationViewModel = HydrationViewModel()
    @State private var showResetAlert = false // State for showing confirmation alert

    // Calculate progress (0 to 1)
    var progress: Double {
        guard hydrationViewModel.dailyWaterGoal > 0 else { return 0 }
        let ratio = hydrationViewModel.currentWaterIntake / hydrationViewModel.dailyWaterGoal
        return ratio.clamped(to: 0...1)
    }


    var body: some View {
        VStack(spacing: 20) {
            Text("Daily Water Intake")
                .font(.title2)
                .fontWeight(.bold)

            // Circular progress view
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.3)
                    .foregroundColor(Color.blue.opacity(0.5))

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(Color.blue, lineWidth: 15)
                    .rotationEffect(.degrees(-90))    // Start from top
                    .animation(.easeOut, value: progress)

                // Display progress and goal
                VStack {
                    Text(String(format: "Progress: %.2f", progress))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(hydrationViewModel.currentWaterIntake)) Bottles")
                        .font(.largeTitle)
                        .bold()
                    Text("Goal: \(Int(hydrationViewModel.dailyWaterGoal)) Bottles")
                        .font(.caption)
                }
            }
            .frame(width: 230, height: 230)
            .padding()

            // Buttons to add water intake
            HStack {
                ForEach([0.5, 1, 2], id: \.self) { bottles in
                    Button(action: {
                        hydrationViewModel.addWater(bottles: bottles)
                    }) {
                        Text(bottles == 0.5 ? "+½ Bottle" : "+\(Int(bottles)) Bottle\(bottles > 1 ? "s" : "")")
                            .font(.headline)
                            .frame(width: 120, height: 45)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                }
            }
            .padding()
            
            // Undo and Reset Buttons
            HStack(spacing: 20) {
                // Undo last entry
                Button(action: {
                    hydrationViewModel.removeLastEntry()
                }) {
                    Text("Undo Last Entry")
                        .font(.headline)
                        .frame(width: 155, height: 50)
                        .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                
                // Reset intake for the day
                Button(action: {
                    showResetAlert = true // Show confirmation alert
                }) {
                    Text("Reset Intake")
                        .font(.headline)
                        .frame(width: 155, height: 50)
                        .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                // Confirm reset alert
                .alert("Reset Water Intake?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        hydrationViewModel.resetManually()
                    }
                } message: {
                    Text("Are you sure you want to reset your daily water intake?")
                }
            }
            
        }
        .padding()
        .onAppear {
            // Refresh hydration factors on load
            hydrationViewModel.fetchUserWeight()
            hydrationViewModel.fetchActiveMinutes()
            hydrationViewModel.fetchWeatherTemperature()
        }
    }
}

#Preview {
    HydrationTrackerView()
}

