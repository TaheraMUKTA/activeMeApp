//
//  HomeViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    let healthManager = HealthManager.shared
    
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0
    //@Published var caloriesData: [Double] = []
   // @Published var activeMinutesData: [Double] = []
    @Published var todayCalories: [Double] = Array(repeating: 0, count: 24)
    @Published var todayActiveMinutes: [Double] = Array(repeating: 0, count: 24)
    @Published var activities = [Activity]()
    @Published var workouts = [Workout]()
    
    var mockActivities = [
        Activity(title: "Today Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "5,850"),
        Activity(title: "Today", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .red, amount: "9,850"),
        Activity(title: "Today Steps", subtitle: "Goal 1,000", image: "figure.walk", tintColor: .blue, amount: "850"),
        Activity(title: "Today Steps", subtitle: "Goal 80,000", image: "figure.run", tintColor: .purple, amount: "65,850")
    ]
    
    var mockWorkouts = [
         Workout(id: 0, tital: "Running", image: "figure.run", tintColor: .cyan, duration: "35 mins", date: "Jan 8", calories: "523 kcal"),
         Workout(id: 1, tital: "Strength Training", image: "figure.strengthtraining.traditional", tintColor: .red, duration: "55 mins", date: "Jan 10", calories: "963 kcal"),
         Workout(id: 2, tital: "Hiking", image: "figure.hiking", tintColor: .purple, duration: "45 mins", date: "Jan 12", calories: "823 kcal"),
         Workout(id: 3, tital: "Swimming", image: "figure.pool.swim", tintColor: .blue, duration: "5 mins", date: "Jan 15", calories: "373 kcal")
    ]
    
    init() {
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
                fetchTodayCalories()
                fetchTodayExerciseTime()
                fetchTodayStandHours()
                fetchTodaySteps()
                fetchCurrentWeekActivities()
                fetchRecentWorkouts()
                //fetchCaloriesOverTime()
                //fetchActiveMinutesOverTime()
               
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func fetchTodayCalories() {
        healthManager.fetchTodayCaloriesBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    self.todayCalories = Array(repeating: 0, count: 24) // Default empty array
                    let hour = Calendar.current.component(.hour, from: Date()) // Get current hour
                    self.todayCalories[hour] = calories
                    let activity = Activity(title: "Calories Burned", subtitle: "Today", image: "flame", tintColor: .red, amount: calories.formattedNumberString())
                    self.activities.append(activity)
                    print("Updated Calories Data: \(self.todayCalories)")
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
            
        }
    }
    
    func fetchTodayExerciseTime() {
        healthManager.fetchTodayExerciseTime { result in
            switch result {
            case .success(let exercise):
                DispatchQueue.main.async {
                    self.exercise = Int(exercise)
                    self.todayActiveMinutes = Array(repeating: 0, count: 24) // Default empty array
                    let hour = Calendar.current.component(.hour, from: Date()) // Get current hour
                    self.todayActiveMinutes[hour] = exercise
                    print("Updated Active Minutes Data: \(self.todayActiveMinutes)")
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
//    
//    func fetchCaloriesOverTime() {
//            healthManager.fetchCaloriesForWeek { result in
//                switch result {
//                case .success(let data):
//                    DispatchQueue.main.async {
//                        self.caloriesData = data
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    
//    func fetchActiveMinutesOverTime() {
//            healthManager.fetchActiveMinutesForWeek { result in
//                switch result {
//                case .success(let data):
//                    DispatchQueue.main.async {
//                        self.activeMinutesData = data
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//        }
    
    
    
    func fetchTodayStandHours() {
        healthManager.fetchTodayStandHours { result in
            switch result {
            case .success(let hours):
                DispatchQueue.main.async {
                    self.stand = hours
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    
    }
    
    // MARK: Fitness Activity
    func fetchTodaySteps() {
        healthManager.fetchTodaySteps{ result in
            switch result {
            case .success(let activity):
                DispatchQueue.main.async {
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func fetchCurrentWeekActivities() {
        healthManager.fetchCurrentWeekWorkoutsStats { result in
            switch result {
            case .success(let activities):
                DispatchQueue.main.async {
                    self.activities.append(contentsOf: activities)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    // MARK: Recent Workouts
    func fetchRecentWorkouts() {
        healthManager.fetchWorkoutsForMonth(month: Date()) { result in
            switch result {
            case .success(let workouts):
                DispatchQueue.main.async {
                    self.workouts = Array(workouts.prefix(4))
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
