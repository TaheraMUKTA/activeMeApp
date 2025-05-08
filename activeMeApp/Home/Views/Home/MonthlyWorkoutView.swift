//
//  MonthlyWorkoutView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 15/03/2025.
//

import SwiftUI

struct MonthlyWorkoutView: View {
    
    @StateObject var workoutViewModel =  MonthlyWorkoutViewModel()
    
    var body: some View {
        VStack {
            // Month navigation with arrows
            HStack {
                Spacer()
                // Left arrow to go to previous month
                Button {
                    withAnimation {
                        workoutViewModel.selectedMonth -= 1
                    }
                } label: {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                }
                Spacer()
                // Displays current selected month and year
                Text(workoutViewModel.selectedDate.monthAndYearFormat())
                    .font(.title)
                    .frame(maxWidth: 250)
                
                Spacer()
                // Right arrow (disabled if already at current month)
                Button {
                    workoutViewModel.selectedMonth += 1
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .opacity(workoutViewModel.selectedMonth >= 0 ? 0.6 : 1)
                }
                .disabled(workoutViewModel.selectedMonth >= 0)
                
                
                Spacer()
            }
            // Workout list for the selected month
            ScrollView(.vertical, showsIndicators: false) {
                if workoutViewModel.currentMonthlyWorkout.isEmpty {
                    // Show message if no workouts found
                    VStack {
                        Text("No workouts found for this month!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                           
                        Text("Stay active and keep moving!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                       
                } else {
                    // Display each workout using a card view
                    ForEach(workoutViewModel.currentMonthlyWorkout, id: \.self) { workout in
                        WorkoutCardView(workout: workout)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical)
        // Load workouts when month changes
        .onChange(of: workoutViewModel.selectedMonth) { _ in
            workoutViewModel.updateSelectedDate()
        }
        .alert("Oops", isPresented: $workoutViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Unable to load workout for \(workoutViewModel.selectedDate.monthAndYearFormat()). Please same sure you have workouts fot the selected month and try again.")
        }
    }
}

#Preview {
    MonthlyWorkoutView()
}
