//
//  HealthManager.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 04/02/2025.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        let calender = Calendar.current
        return calender.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calender = Calendar.current
        var components = calender.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        return calender.date(from: components) ?? Date()
    }
    
    func fetchMonthStartAndEndDate() -> (Date, Date) {
        let calender = Calendar.current
        let startDateComponent = calender.dateComponents([.year, .month], from: calender.startOfDay(for: self))
        let startDate = calender.date(from: startDateComponent) ?? self
        let endDate = calender.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) ?? self
        return (startDate, endDate)
    }
    
    func formatWorkoutDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

}

extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

class HealthManager {
    
    static let shared = HealthManager()
    
    let healthStore = HKHealthStore()
    
    private init () {
        
        Task {
            do {
                try await requestHealthKitAccess()
                enableBackgroundDelivery()
                startObservingHealthData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestHealthKitAccess() async throws {
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        let steps = HKQuantityType(.stepCount)
        let workouts = HKSampleType.workoutType()
        
        let healthTypes: Set = [calories, exercise, stand, steps, workouts]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodayCaloriesBurned(completion: @escaping(Result<Double, Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
               
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
            
        }
        healthStore.execute(query)
    }
    
    func fetchTodayExerciseTime(completion: @escaping(Result<Double, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
               
            let exerciseTime = quantity.doubleValue(for: .minute())
            completion(.success(exerciseTime))
            
        }
        healthStore.execute(query)
    }
    
    func fetchTodayStandHours(completion: @escaping(Result<Int, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
                
            }
            
            let standCount = samples.filter({ $0.value == 0}).count
            
            completion(.success(standCount))
        }
        
        healthStore.execute(query)
    }
    
    func fetchHourlyCaloriesBurned(completion: @escaping(Result<[Int: Double], Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        let now = Date()

        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: now)

        let query = HKStatisticsCollectionQuery(
            quantityType: calories,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: Date.startOfDay,
            intervalComponents: DateComponents(hour: 1)
        )

        query.initialResultsHandler = { _, results, error in
            guard let results = results, error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }

            var hourlyData: [Int: Double] = [:]

            results.enumerateStatistics(from: .startOfDay, to: now) { statistics, _ in
                let hour = calendar.component(.hour, from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                hourlyData[hour] = value > 0 ? value : nil // Only store non-zero values
            }

            completion(.success(hourlyData))
        }

        healthStore.execute(query)
    }
    
    
    func fetchHourlyExerciseTime(completion: @escaping(Result<[Int: Double], Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let calendar = Calendar.current
        let now = Date()

        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: now)

        let query = HKStatisticsCollectionQuery(
            quantityType: exercise,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: Date.startOfDay,
            intervalComponents: DateComponents(hour: 1)
        )

        query.initialResultsHandler = { _, results, error in
            guard let results = results, error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }

            var hourlyData: [Int: Double] = [:]

            results.enumerateStatistics(from: .startOfDay, to: now) { statistics, _ in
                let hour = calendar.component(.hour, from: statistics.startDate)
                if let value = statistics.sumQuantity()?.doubleValue(for: .minute()), value > 0 {
                    hourlyData[hour] = value
                }
            }

            DispatchQueue.main.async {
                completion(.success(hourlyData))
            }
        }

        healthStore.execute(query)
    }


    
//    func fetchCaloriesForWeek(completion: @escaping(Result<[Double], Error>) -> Void) {
//            let calories = HKQuantityType(.activeEnergyBurned)
//            let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//            let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
//            
//            let query = HKStatisticsCollectionQuery(quantityType: calories, quantitySamplePredicate: predicate,
//                options: .cumulativeSum, anchorDate: startOfWeek, intervalComponents: DateComponents(day: 1))
//
//            query.initialResultsHandler = { _, results, error in
//                guard let results = results, error == nil else {
//                    completion(.failure(error ?? NSError()))
//                    return
//                }
//
//                var data: [Double] = []
//                results.enumerateStatistics(from: startOfWeek, to: Date()) { stat, _ in
//                    let value = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
//                    data.append(value)
//                }
//
//                completion(.success(data))
//            }
//
//            healthStore.execute(query)
//        }
    
//    func fetchActiveMinutesForWeek(completion: @escaping(Result<[Double], Error>) -> Void) {
//            let exerciseTime = HKQuantityType(.appleExerciseTime)
//            let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//            let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
//            
//            let query = HKStatisticsCollectionQuery(quantityType: exerciseTime, quantitySamplePredicate: predicate,
//                options: .cumulativeSum, anchorDate: startOfWeek, intervalComponents: DateComponents(day: 1))
//
//            query.initialResultsHandler = { _, results, error in
//                guard let results = results, error == nil else {
//                    completion(.failure(error ?? NSError()))
//                    return
//                }
//
//                var data: [Double] = []
//                results.enumerateStatistics(from: startOfWeek, to: Date()) { stat, _ in
//                    let value = stat.sumQuantity()?.doubleValue(for: .minute()) ?? 0
//                    data.append(value)
//                }
//
//                completion(.success(data))
//            }
//
//            healthStore.execute(query)
//        }
    
    
    
    
    // MARK: Fitness Activity
    func fetchTodaySteps(completion: @escaping(Result<Activity, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
               
            let steps = quantity.doubleValue(for: .count())
            let activity = Activity(title: "Today Steps", subtitle: "Goal: 800", image: "figure.walk", tintColor: .green, amount: steps.formattedNumberString())
            completion(.success(activity))
        }
        
        healthStore.execute(query)
    }
    
    func fetchCurrentWeekWorkoutsStats(completion: @escaping(Result<[Activity], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            var runningCount: Int = 0
            var cyclingCount: Int = 0
            var swimmingCount: Int = 0
            var stairsCount: Int = 0
            var hikingCount: Int = 0
            var strengthCount: Int = 0
             
            for workout in workouts {
                let duration = Int(workout.duration)/60
                if workout.workoutActivityType == .running {
                    runningCount += duration
                } else if workout.workoutActivityType == .cycling {
                    cyclingCount += duration
                } else if workout.workoutActivityType == .swimming {
                    swimmingCount += duration
                } else if workout.workoutActivityType == .stairClimbing {
                    stairsCount += duration
                } else if workout.workoutActivityType == .hiking {
                    hikingCount += duration
                } else if workout.workoutActivityType == .traditionalStrengthTraining {
                    strengthCount += duration
                }
            }
            
            completion(.success(self.generateActivitiesFromDurations(running: runningCount, cycling: cyclingCount, swimming: swimmingCount, stairs: stairsCount, hiking: hikingCount, strength: strengthCount)))
            
        }
        healthStore.execute(query)
    }
    
    func generateActivitiesFromDurations(running: Int, cycling: Int, swimming: Int, stairs: Int, hiking: Int, strength: Int) -> [Activity] {
        return [
            Activity(title: "Running", subtitle: "This week", image: "figure.run", tintColor: .green, amount: "\(running) mins"),
            Activity(title: "Cycling", subtitle: "This week", image: "figure.outdoor.cycle", tintColor: .blue, amount: "\(cycling) mins"),
            Activity(title: "Swimming", subtitle: "This week", image: "figure.pool.swim", tintColor: .indigo, amount: "\(swimming) mins"),
            Activity(title: "Stairs Climbing", subtitle: "This week", image: "figure.stairs", tintColor: .purple, amount: "\(stairs) mins"),
            Activity(title: "Hiking", subtitle: "This week", image: "figure.hiking", tintColor: .cyan, amount: "\(hiking) mins"),
            Activity(title: "Strength Training", subtitle: "This week", image: "dumbbell", tintColor: .orange, amount: "\(strength) mins")
        ]
    }
    
    // MARK: Recent Workouts
    func fetchWorkoutsForMonth(month: Date, completion: @escaping(Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let (startDate, endDate) = month.fetchMonthStartAndEndDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let workouts = results as? [HKWorkout], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            // Print the fetched workouts
                    for workout in workouts {
                        print("Fetched Workout: \(workout.workoutActivityType.name) - \(workout.duration/60) mins")
                    }
            
            let workoutsArray = workouts.map({ Workout(id: nil, tital: $0.workoutActivityType.name, image: $0.workoutActivityType.image, tintColor: $0.workoutActivityType.color, duration: "\(Int($0.duration)/60) mins", date: $0.startDate.formatWorkoutDate(), calories: ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()).formattedNumberString() ?? "-") + "kcal") })
            completion(.success(workoutsArray))
            
        }
        healthStore.execute(query)
    }
    
    
    
    func enableBackgroundDelivery() {
        let healthTypes: [HKObjectType] = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        for type in healthTypes {
            healthStore.enableBackgroundDelivery(for: type, frequency: .hourly) { success, error in
                if let error = error {
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                } else {
                    print("Background delivery enabled for \(type.identifier)")
                }
            }
        }
    }

    
    func startObservingHealthData() {
        let healthTypes: [HKSampleType] = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        for type in healthTypes {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { query, completionHandler, error in
                if let error = error {
                    print("Observer query error: \(error.localizedDescription)")
                    return
                }
                
                print("HealthKit data updated for: \(type.identifier)")
                
                // Fetch updated data and refresh UI
                Task {
                    await HomeViewModel.shared.refreshAllData()
                }
                
                completionHandler() // Must call this when done
            }
            healthStore.execute(query)
        }
    }

    
    
}
