//
//  HomeViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    let healthManager = HealthManager.shared
    
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0
    @Published var todayCalories: [Double?] = Array(repeating: nil, count: 24)
    @Published var todayActiveMinutes: [Double?] = Array(repeating: nil, count: 24)
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
                fetchAllHealthData()
               
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func fetchAllHealthData() {
        
        fetchHourlyCalories()
        fetchHourlyExercise()
        fetchTodayCalories()
        fetchTodayExerciseTime()
        fetchTodayStandHours()
        fetchTodaySteps()
        fetchCurrentWeekActivities()
        fetchRecentWorkouts()
        fetchTodayActiveTime()
        fetchTodayStandTime()
    }
    
    func refreshAllData() async {
        await MainActor.run {
            self.fetchAllHealthData()
        }
    }

    
    
    
    func fetchTodayCalories() {
        healthManager.fetchTodayCaloriesBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    
                    let activity = Activity(
                        title: "Calories Burned",
                        subtitle: "Today",
                        image: "flame",
                        tintColor: .red,
                        amount: "\(calories.formattedNumberString()) kcal")
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
                    
                    print("Updated Active Minutes Data: \(self.todayActiveMinutes)")
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    
    func fetchHourlyCalories() {
        healthManager.fetchHourlyCaloriesBurned { result in
            switch result {
            case .success(let hourlyCalories):
                DispatchQueue.main.async {
                    let currentHour = Calendar.current.component(.hour, from: Date())

                    for hour in 0...currentHour {
                        if let value = hourlyCalories[hour] {
                            self.todayCalories[hour] = value
                        }
                    }

                    // Calculate total calories burned for the day
                    self.calories = Int(self.todayCalories.compactMap { $0 }.reduce(0, +))

                    print("Updated Hourly Calories Data: \(self.todayCalories)")
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    func fetchHourlyExercise() {
        healthManager.fetchHourlyExerciseTime { result in
            switch result {
            case .success(let hourlyExercise):
                DispatchQueue.main.async {
                    let currentHour = Calendar.current.component(.hour, from: Date())

                    for hour in 0...currentHour {
                        if let value = hourlyExercise[hour] {
                            self.todayActiveMinutes[hour] = value
                        }
                    }

                    // Ensure the total active minutes for the day are calculated correctly
                    self.exercise = Int(self.todayActiveMinutes.compactMap { $0 }.reduce(0, +))

                    // Force UI update
                    self.objectWillChange.send()

                    print("Updated Hourly Active Minutes Data: \(self.todayActiveMinutes)")
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    
    func fetchTodayActiveTime() {
        healthManager.fetchTodayActiveTimeAsActivity { result in
            switch result {
            case .success(let activity):
                DispatchQueue.main.async {
                    // Check if already present, then update
                    if let index = self.activities.firstIndex(where: { $0.title == "Active Time" }) {
                        self.activities[index] = activity
                    } else {
                        self.activities.append(activity)
                    }
                }
            case .failure(let error):
                print("Error fetching Active Time: \(error.localizedDescription)")
            }
        }
    }

    
    func fetchTodayStandTime() {
        healthManager.fetchTodayStandTimeAsActivity { result in
            switch result {
            case .success(let activity):
                DispatchQueue.main.async {
                    // Check if already present, then update
                    if let index = self.activities.firstIndex(where: { $0.title == "Stand Time" }) {
                        self.activities[index] = activity
                    } else {
                        self.activities.append(activity)
                    }
                }
            case .failure(let error):
                print("Error fetching Stand Time: \(error.localizedDescription)")
            }
        }
    }
    
    
    
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
