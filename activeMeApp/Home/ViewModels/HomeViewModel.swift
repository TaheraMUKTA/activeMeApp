//
//  HomeViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @State var calories: Int = 123
    @State var active: Int = 45
    @State var stand: Int = 8
    var mockActivities = [
        Activity(id: 0, title: "Today Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "5,850"),
        Activity(id: 1, title: "Today", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .red, amount: "9,850"),
        Activity(id: 2, title: "Today Steps", subtitle: "Goal 1,000", image: "figure.walk", tintColor: .blue, amount: "850"),
        Activity(id: 3, title: "Today Steps", subtitle: "Goal 80,000", image: "figure.run", tintColor: .purple, amount: "65,850")
    ]
    
    var mockWorkouts = [
         Workout(id: 0, tital: "Running", image: "figure.run", tintColor: .cyan, duration: "35 mins", date: "Jan 8", calories: "523 kcal"),
         Workout(id: 1, tital: "Strength Training", image: "figure.strengthtraining.traditional", tintColor: .red, duration: "55 mins", date: "Jan 10", calories: "963 kcal"),
         Workout(id: 2, tital: "Hiking", image: "figure.hiking", tintColor: .purple, duration: "45 mins", date: "Jan 12", calories: "823 kcal"),
         Workout(id: 3, tital: "Swimming", image: "figure.pool.swim", tintColor: .blue, duration: "5 mins", date: "Jan 15", calories: "373 kcal")
    ]
}
