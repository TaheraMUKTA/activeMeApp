//
//  WorkoutCardView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct Workout {
    let id: Int
    let tital: String
    let image: String
    let tintColor: Color
    let duration: String
    let date: String
    let calories: String
}

struct WorkoutCardView: View {
    @State var workout: Workout
    var body: some View {
        HStack {
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(workout.tintColor)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            VStack(spacing: 16) {
                HStack {
                    Text(workout.tital)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text(workout.duration)
                        .font(.headline)
                        .fontWeight(.regular)
                }
                HStack {
                    Text(workout.date)
                        .font(.headline)
                        .fontWeight(.regular)
                    Spacer()
                    Text(workout.calories)
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
        WorkoutCardView(workout: Workout(id: 0, tital: "Running", image: "figure.run", tintColor: .cyan, duration: "35 mins", date: "Jan 8", calories: "523 kcal"))
    }
}
