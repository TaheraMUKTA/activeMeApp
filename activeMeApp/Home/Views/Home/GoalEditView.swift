//
//  GoalEditView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 16/03/2025.
//

import SwiftUI

struct GoalEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var homeViewModel: HomeViewModel // Use shared instance

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Edit Goals")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 20)

                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                }

                // Sliders for editing goals
                Form {
                    Section(header: Text("Set Your Goals")) {
                        GoalSlider(title: "Calories Goal:", value: $homeViewModel.caloriesGoal, range: 50...3000, step: 50, color: .red)
                        GoalSlider(title: "Active Goal:", value: $homeViewModel.activeGoal, range: 5...90, step: 5, color: .green)
                        GoalSlider(title: "Stand Goal:", value: $homeViewModel.standGoal, range: 6...18, step: 1, color: .blue)
                    }
                }

                // Save & Cancel Buttons
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()   // Close the sheet
                    }
                    .buttonStyle(GoalButtonStyle(backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9)))
                    .padding()

                    Button("Save") {
                        Task {
                            // Save goals to Firestore
                            await homeViewModel.saveGoalsToFirestore() // Save & refresh
                            await homeViewModel.fetchUserGoals()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .buttonStyle(GoalButtonStyle(backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9)))
                    .padding()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
            }
        }
    }
}

// Extract Slider into a Reusable View
struct GoalSlider: View {
    var title: String
    @Binding var value: Int
    var range: ClosedRange<Double>
    var step: Double
    var color: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)   // Title of the slider
                    .font(.title3)
                    .foregroundColor(color.opacity(0.9))
                    .bold(true)
                Spacer()
                Text("\(value)")   // Current value of the slider
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.9))
                    .bold(true)
            }
            // Slider with defined range and step
            Slider(value: Binding(get: {
                Double(value)
            }, set: { newValue in
                value = Int(newValue)
            }), in: range, step: step)
            .accentColor(color)
            .bold(true)
        }
        .padding(.vertical, 20)
    }
}

//  Extract Button Style
struct GoalButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .bold(true)
            .background(backgroundColor)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)   // Button press effect
    }
}


struct GoalEditView_Previews: PreviewProvider {
    static var previews: some View {
        GoalEditView()
            .environmentObject(HomeViewModel())
    }
}
