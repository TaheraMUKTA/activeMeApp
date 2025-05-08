//
//  HomeViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    
    // Firestore database and HealthKit manager instances
    private let db = Firestore.firestore()
    let healthManager = HealthManager.shared
    
    // MARK: Published properties to update the UI
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0
    
    // User-set goals (fetched from Firestore or defaults)
    @Published var caloriesGoal: Int = 350
    @Published var activeGoal: Int = 30
    @Published var standGoal: Int = 8
    
    // Hourly data for chart use
    @Published var todayCalories: [Double?] = Array(repeating: nil, count: 24)
    @Published var todayActiveMinutes: [Double?] = Array(repeating: nil, count: 24)
    
    // Displayed summaries and workout history
    @Published var activities = [Activity]()
    @Published var workouts = [Workout]()
    
    // State flags for error handling or loading
    @Published var presentError = false
    @Published var isLoading = false
    @Published var showError = false
    
    // Firebase Auth user ID
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: Init - Load all data on start
     init() {
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
                
                async let fetchCalories: () = try await fetchTodayCalories()
                async let fetchExercise: () = try await fetchTodayExerciseTime()
                async let fetchStand: () = try await fetchTodayStandHours()
                async let fetchSteps: () = try await fetchTodaySteps()
                async let fetchActivities: () = try await fetchCurrentWeekActivities()
                async let fetchWorkouts: () = try await fetchRecentWorkouts()
                await fetchUserGoals()   // Load goals before chart data
                fetchAllHealthData()
                
                // Wait for all async tasks to complete
               let (_, _, _, _, _, _) = (try await fetchCalories, try await fetchExercise, try await fetchStand, try await fetchSteps, try await fetchActivities, try await fetchWorkouts)
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
               
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.presentError = true
                }
            }
        }
    }
 
    // Fetch all health data after loading user goals
    func fetchAllHealthData() {
        fetchHourlyCalories()
        fetchHourlyExercise()
        fetchTodayActiveTime()
        fetchTodayStandTime()
    }
    
    func refreshAllData() async {
        await MainActor.run {
            self.fetchAllHealthData()
        }
    }

    // Fetch today's total calories burned
    func fetchTodayCalories() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchTodayCaloriesBurned { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let calories):
                    DispatchQueue.main.async {
                        self.calories = Int(calories)
                        self.activities.removeAll { $0.title == "Calories Burned" }
                        let activity = Activity(
                            title: "Calories Burned",
                            subtitle: "Today",
                            image: "flame",
                            tintColor: .red,
                            amount: "\(calories.formattedNumberString()) kcal")
                        self.activities.append(activity)
                        Task {
                            await self.saveHealthDataToFirestore()
                        }
                        continuation.resume()
                        print("Updated Calories Data: \(self.todayCalories)")
                    }
                case .failure(let failure):
                    DispatchQueue.main.async {
                        let activity = Activity(
                            title: "Calories Burned",
                            subtitle: "Today",
                            image: "flame",
                            tintColor: .red,
                            amount: "--- kcal")
                        self.activities.append(activity)
                        print("Updated Calories Data: \(self.todayCalories)")
                        continuation.resume(throwing: failure)
                    }
                }
            }
        }) as Void
    }
    
    // Fetch today’s total active time
    func fetchTodayExerciseTime() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchTodayExerciseTime { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let exercise):
                    DispatchQueue.main.async {
                        self.exercise = Int(exercise)
                        self.activities.removeAll { $0.title == "Active Time" }
                        Task {
                            await self.saveHealthDataToFirestore()
                        }
                        continuation.resume()
                        print("Updated Active Minutes Data: \(self.todayActiveMinutes)")
                    }
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }) as Void
    }
    
    // Hourly calories data for charts
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

    // Hourly exercise data for charts
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

    // Show activity card for active time
    func fetchTodayActiveTime() {
        healthManager.fetchTodayActiveTimeAsActivity { result in
            let fallbackActivity = Activity(
                title: "Active Time",
                subtitle: "Today",
                image: "figure.walk",
                tintColor: .orange,
                amount: "0 mins"
            )
            DispatchQueue.main.async {
                switch result {
                case .success(let activity):
                    // Check if already present, then update
                    if let index = self.activities.firstIndex(where: { $0.title == "Active Time" }) {
                        self.activities[index] = activity
                    } else {
                        self.activities.append(activity)
                        
                    }
                case .failure(let error):
                    print("Error fetching Active Time: \(error.localizedDescription)")
                    
                    if !self.activities.contains(where: { $0.title == "Active Time" }) {
                        self.activities.append(fallbackActivity)
                    }
                }
            }
        }
    }

    // Show activity card for stand time
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

    // Fetch today’s stand hours
    func fetchTodayStandHours() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchTodayStandHours { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let hours):
                    DispatchQueue.main.async {
                        self.stand = hours
                        self.activities.removeAll { $0.title == "Stand Time" }
                        Task {
                            await self.saveHealthDataToFirestore()
                        }
                        continuation.resume()
                    }
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }) as Void
    }
    
    // Fetch today’s step count
    func fetchTodaySteps() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchTodaySteps{ [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let activity):
                    DispatchQueue.main.async {
                        self.activities.removeAll { $0.title == "Today Steps" }
                        self.activities.append(activity)
                        Task {
                            await self.saveHealthDataToFirestore()
                        }
                        continuation.resume()
                    }
                case .failure(let failure):
                    DispatchQueue.main.async {
                        self.activities.append(Activity(
                            title: "Today Steps",
                            subtitle: "Goal: 800",
                            image: "figure.walk",
                            tintColor: .green,
                            amount: "---"))
                    }
                    continuation.resume(throwing: failure)
                }
            }
        }) as Void
    }
    
    // MARK: Fitness Activity
    
    func fetchCurrentWeekActivities() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchCurrentWeekWorkoutsStats { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let activities):
                    DispatchQueue.main.async {
                        let validActivities = activities.map { activity in
                            Activity(
                                title: activity.title,
                                subtitle: activity.subtitle,
                                image: activity.image,
                                tintColor: activity.tintColor,
                                amount: activity.amount.isEmpty ? "0 mins" : activity.amount
                            )
                        }
                        self.activities.append(contentsOf: validActivities.prefix(10))
                    
                        continuation.resume()
                    }
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }) as Void
    }
    
    
    // MARK: Recent Workouts
    func fetchRecentWorkouts() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchWorkoutsForWeek { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let workouts):
                    DispatchQueue.main.async {
                        if let storedWeekStart = UserDefaults.standard.object(forKey: "storedWeekStart") as? Date {
                            if !Calendar.current.isDate(storedWeekStart, inSameDayAs: Date.startOfWeek) {
                                self.workouts.removeAll()
                                UserDefaults.standard.set(Date.startOfWeek, forKey: "storedWeekStart")
                            }
                        } else {
                            UserDefaults.standard.set(Date.startOfWeek, forKey: "storedWeekStart")
                        }
                        self.workouts = Array(workouts.prefix(4))
                        Task {
                            await self.saveHealthDataToFirestore()
                        }
                        continuation.resume()
                    }
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }) as Void
    }
    
    // Load user goals from Firestore or local storage
    func fetchUserGoals() async {
            guard let userId = userId else { return }

        let docRef = db.collection("healthData").document(userId)

            do {
                let document = try await docRef.getDocument()
                if document.exists, let data = document.data() {
                    // Only update the goals if they are still the default values (user has not edited them)
                    if let savedCaloriesGoal = UserDefaults.standard.value(forKey: "caloriesGoal") as? Int {
                        self.caloriesGoal = savedCaloriesGoal
                    } else {
                        self.caloriesGoal = data["caloriesGoal"] as? Int ?? 350
                    }

                    if let savedActiveGoal = UserDefaults.standard.value(forKey: "activeGoal") as? Int {
                        self.activeGoal = savedActiveGoal
                    } else {
                        self.activeGoal = data["activeGoal"] as? Int ?? 30
                    }

                    if let savedStandGoal = UserDefaults.standard.value(forKey: "standGoal") as? Int {
                        self.standGoal = savedStandGoal
                    } else {
                        self.standGoal = data["standGoal"] as? Int ?? 8
                    }
                    self.objectWillChange.send()
                }
            } catch {
                print("Error fetching goals: \(error.localizedDescription)")
                showError = true
            }

            DispatchQueue.main.async {
                self.objectWillChange.send() // Force UI update
            }
        }

    // Save updated goals to Firestore
        func saveGoalsToFirestore() async {
            guard let userId = userId else { return }

            let goalData: [String: Any] = [
                "caloriesGoal": caloriesGoal,
                "activeGoal": activeGoal,
                "standGoal": standGoal,
                "lastUpdated": Timestamp(date: Date())
            ]

            do {
                try await db.collection("healthData").document(userId).setData(goalData, merge: true)
                print("Goals successfully updated in Firestore")
                UserDefaults.standard.set(caloriesGoal, forKey: "caloriesGoal")
                UserDefaults.standard.set(activeGoal, forKey: "activeGoal")
                UserDefaults.standard.set(standGoal, forKey: "standGoal")
                await fetchUserGoals() // Refresh UI immediately
            } catch {
                print("Error saving goals: \(error.localizedDescription)")
                showError = true
            }
        }
    
    // MARK: Saves health data to Firestore
        func saveHealthDataToFirestore() async {
            guard let userId = userId else { return }
            
            let workoutsData = workouts.map { workout in
                return [
                    "title": workout.title,
                    "image": workout.image,
                    "tintColor": workout.tintColor.toHexString(),
                    "duration": workout.duration,
                    "date": workout.date,
                    "calories": workout.calories
                ]
            }

            let healthData: [String: Any] = [
                "caloriesGoal": caloriesGoal,
                "activeGoal": activeGoal,
                "standGoal": standGoal,
                "caloriesBurned": calories,
                "activeMinutes": exercise,
                "standHours": stand,
                "lastUpdated": Timestamp(date: Date()),
                "workouts": workoutsData      // Store Workouts
            ]

            do {
                try await db.collection("healthData").document(userId).setData(healthData, merge: true)
                print("Health data successfully updated for user: \(userId)")
            } catch {
                print("Error saving health data: \(error.localizedDescription)")
            }
        }



    // Real-time listener to sync Firestore updates
    func listenForHealthDataUpdates() {
        guard let userId = userId else { return }
        db.collection("healthData").document(userId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error listening for changes: \(error.localizedDescription)")
                return
            }
            if let document = documentSnapshot, let data = document.data() {
                DispatchQueue.main.async {
                    self.calories = data["caloriesBurned"] as? Int ?? 0
                    self.exercise = data["activeMinutes"] as? Int ?? 0
                    self.stand = data["standHours"] as? Int ?? 0
                    self.objectWillChange.send()
                }
            }
        }
    }
}
