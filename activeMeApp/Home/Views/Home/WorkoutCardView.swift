//
//  WorkoutCardView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI


struct WorkoutCardView: View {
    @State var workout: Workout
    var body: some View {
        HStack {
            // Workout icon
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(workout.tintColor)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // Workout details section
            VStack(spacing: 16) {
                HStack {
                    Text(workout.title)    // Workout name (e.g., "Running")
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text(workout.duration)    // Duration (e.g., "35 mins")
                        .font(.headline)
                        .fontWeight(.regular)
                }
                HStack {
                    Text(workout.date.formatWorkoutDate())    // Formatted date (e.g., "Apr 20")
                        .font(.headline)
                        .fontWeight(.regular)
                    Spacer()
                    Text(workout.calories)      // Calories burned (e.g., "523 kcal")
                        .font(.headline)
                        .fontWeight(.regular)
                       
                }
            }
        }
        .padding(.horizontal)
    }
}

struct WorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCardView(workout: Workout(title: "Running", image: "figure.run", tintColor: .cyan, duration: "35 mins", date: Date(), calories: "523 kcal"))
    }
}
