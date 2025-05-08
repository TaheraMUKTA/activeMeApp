//
//  HydrationViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 29/03/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import HealthKit

// Get current user ID from Firebase Auth
var userId: String? {
    return Auth.auth().currentUser?.uid
}

class HydrationViewModel: ObservableObject {
    @Published var currentWaterIntake: Double = UserDefaults.standard.double(forKey: "currentWaterIntake")
    @Published var dailyWaterGoal: Double = UserDefaults.standard.double(forKey: "dailyWaterGoal") == 0 ? 4 : UserDefaults.standard.double(forKey: "dailyWaterGoal") // Default = 4 Bottles (2L)
    @Published var weight: Double = 70 // Default user weight
    @Published var temperature: Double = 20 // Default temperature
    @Published var activeMinutes: Double = 0 // Default active time
    
    private let bottleSize: Double = 500 // 1 bottle = 500ml
    private var lastAdded: Double = 0 // Store last added value
    
    private let db = Firestore.firestore()
    private let healthStore = HKHealthStore()

    // MARK: - Init
    init() {
        checkIfNewDay()
        resetAtMidnight()
        fetchUserWeight()
        fetchActiveMinutes()
        fetchWeatherTemperature()
    }
    
    // Fetch User Weight from Firebase
    func fetchUserWeight() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let weightString = data["weight"] as? String, let weight = Double(weightString) {
                DispatchQueue.main.async {
                    self.weight = weight
                    self.calculateHydrationGoal()
                }
            }
        }
    }

    // Fetch Active Minutes from HealthKit
    func fetchActiveMinutes() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
            
        let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let startDate = Calendar.current.startOfDay(for: Date()) // Today’s data
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
            
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity() {
                let minutes = sum.doubleValue(for: HKUnit.minute()) // Convert to minutes
                DispatchQueue.main.async {
                    self.activeMinutes = minutes
                    self.calculateHydrationGoal()
                }
            }
        }
        healthStore.execute(query)
    }

    // Fetch Current Temperature using OpenWeather API
    func fetchWeatherTemperature() {
        let apiKey = "3cf82208c8102aa6f5d51e744d7d19c9"
        let city = "London"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)

                DispatchQueue.main.async {
                    self.temperature = decodedData.main.temp
                    self.calculateHydrationGoal() // Update hydration goal after fetching temp
                }
            } catch {
                print("Error fetching weather: \(error.localizedDescription)")
            }
        }
    }


    // Calculate Hydration Goal based on weight, exercise, and weather
    func calculateHydrationGoal() {
        var baseGoalML = weight * 35 // Convert weight to ml (35ml per kg)

        if activeMinutes > 30 { baseGoalML += 500 }  // Add 500ml if moderately active
        if activeMinutes > 60 { baseGoalML += 1000 } // Add 1L for heavy exercise
        if temperature > 30 { baseGoalML += 500 }    // Add 500ml for hot weather

        var baseGoalBottles = baseGoalML / bottleSize // Convert to bottles

            // Enforce minimum of 4 bottles (2L)
        baseGoalBottles = max(baseGoalBottles, 4)

            // Round to nearest whole number
        baseGoalBottles = round(baseGoalBottles)

        DispatchQueue.main.async {
            self.dailyWaterGoal = baseGoalBottles
            UserDefaults.standard.set(self.dailyWaterGoal, forKey: "dailyWaterGoal")
            self.saveWaterIntakeToFirestore()
        }
    }
                                                                    
    // Add Water Intake
    func addWater(bottles: Double) {
        lastAdded = bottles
        currentWaterIntake += bottles
        UserDefaults.standard.set(currentWaterIntake, forKey: "currentWaterIntake")
        saveWaterIntakeToFirestore()
    }

    // Undo Last Entry
    func removeLastEntry() {
        guard currentWaterIntake - lastAdded >= 0 else {
            currentWaterIntake = 0
            UserDefaults.standard.set(0, forKey: "currentWaterIntake")
            saveWaterIntakeToFirestore()
            return
        }
        currentWaterIntake -= lastAdded
        UserDefaults.standard.set(currentWaterIntake, forKey: "currentWaterIntake")
        lastAdded = 0 // Reset after undo
        saveWaterIntakeToFirestore()
    }
    
    // Manual Reset (e.g. via UI)
    func resetManually() {
        currentWaterIntake = 0
        UserDefaults.standard.set(0, forKey: "currentWaterIntake")
        saveWaterIntakeToFirestore()
    }

    // Automatic Reset at Midnight
    private func resetAtMidnight() {
        let calendar = Calendar.current
        let now = Date()
        if let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .strict) {
            let timeInterval = nextMidnight.timeIntervalSince(now)
            
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                self.resetWaterIntake()
                self.resetAtMidnight()
            }
        }
    }
    
    // Check if a New Day Has Started (App Relaunch)
    private func checkIfNewDay() {
        let lastDate = UserDefaults.standard.object(forKey: "lastHydrationResetDate") as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: Date())
        
        if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            resetWaterIntake()
            UserDefaults.standard.set(today, forKey: "lastHydrationResetDate")
        }
    }

    // Reset Intake to 0
    private func resetWaterIntake() {
        DispatchQueue.main.async {
            self.currentWaterIntake = 0
            UserDefaults.standard.set(0, forKey: "currentWaterIntake")
        }
    }
    
    // Save to Firestore (goal + intake)
    func saveWaterIntakeToFirestore() {
        guard let userId = userId else { return }

        let data: [String: Any] = [
            "dailyWaterGoal": dailyWaterGoal,
            "currentWaterIntake": currentWaterIntake,
            "hydrationLastUpdated": Timestamp(date: Date())
        ]

        db.collection("healthData").document(userId).setData(data, merge: true) { error in
            if let error = error {
                print("Failed to save water intake: \(error.localizedDescription)")
            } else {
                print("Water intake data successfully saved.")
            }
        }
    }
}
