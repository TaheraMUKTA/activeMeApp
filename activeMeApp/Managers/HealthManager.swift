//
//  HealthManager.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 04/02/2025.
//

import SwiftUI
import HealthKit

// Singleton class to manage HealthKit data
class HealthManager {
    
    static let shared = HealthManager()
    
    let healthStore = HKHealthStore()
    
    private init () {
        // it request access and enable background updates
        Task {
            do {
                try await requestHealthKitAccess()
                enableBackgroundDelivery()
                startObservingHealthData()
            } catch {
                DispatchQueue.main.async {
                    presentAlert(title: "Oops!", message: "We were unable to access health data. Please allow access to enjoy activeMe app.")
                }
            }
        }
    }
    
    // Ask user for permission to read health data
    func requestHealthKitAccess() async throws {
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        let steps = HKQuantityType(.stepCount)
        let workouts = HKSampleType.workoutType()
        
        let healthTypes: Set = [calories, exercise, stand, steps, workouts]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    // Fetch calories burned today
    func fetchTodayCaloriesBurned(completion: @escaping(Result<Double, Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        // Use statistics query to get total calories
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error!))
                return
            }
               
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
            
        }
        healthStore.execute(query)
    }
    
    // Fetch total exercise minutes today
    func fetchTodayExerciseTime(completion: @escaping(Result<Double, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error!))
                return
            }
               
            let exerciseTime = quantity.doubleValue(for: .minute())
            completion(.success(exerciseTime))
            
        }
        healthStore.execute(query)
    }
    
    // Fetch number of stand hours today
    func fetchTodayStandHours(completion: @escaping(Result<Int, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(error!))
                return
                
            }
            // Count how many stand hours were not achieved (value == 0)
            let standCount = samples.filter({ $0.value == 0}).count
            
            completion(.success(standCount))
        }
        
        healthStore.execute(query)
    }
    
    // Fetch calories burned for each hour of today
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

            // Loop through each hour and store calories
            results.enumerateStatistics(from: .startOfDay, to: now) { statistics, _ in
                let hour = calendar.component(.hour, from: statistics.startDate)
                let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                hourlyData[hour] = value > 0 ? value : nil // Only store non-zero values
            }

            completion(.success(hourlyData))
        }

        healthStore.execute(query)
    }
    
    // Fetch exercise time per hour today
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

    
    
    // MARK: Fitness Activity
    
    // Fetch steps for today and return as Activity model
    func fetchTodaySteps(completion: @escaping(Result<Activity, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error!))
                return
            }
            // Convert step count and wrap in Activity model
            let steps = quantity.doubleValue(for: .count())
            let activity = Activity(
                title: "Today Steps",
                subtitle: "Goal: 800",
                image: "figure.walk",
                tintColor: .green,
                amount: steps.formattedNumberString())
            completion(.success(activity))
        }
        
        healthStore.execute(query)
    }
    
    // Fetch active time for today as Activity
    func fetchTodayActiveTimeAsActivity(completion: @escaping (Result<Activity, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error!))
                return
            }
            // Return active minutes as an Activity
            let activeTime = quantity.doubleValue(for: .minute())
            let activity = Activity(
                title: "Active Time",
                subtitle: "Today",
                image: "figure.walk.circle",  // Use a relevant SF Symbol or custom image
                tintColor: .orange,
                amount: "\(Int(activeTime)) mins"
            )
            completion(.success(activity))
        }
        healthStore.execute(query)
    }

    // Fetch stand time for today as Activity
    func fetchTodayStandTimeAsActivity(completion: @escaping (Result<Activity, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(error!))
                return
            }
            // Count stand hours (value == 0 means user stood up)
            let standCount = samples.filter({ $0.value == 0 }).count
            let activity = Activity(
                title: "Stand Time",
                subtitle: "Today",
                image: "figure.stand",  // Use a relevant SF Symbol or custom image
                tintColor: .blue,
                amount: "\(standCount) hours"
            )
            completion(.success(activity))
        }
        healthStore.execute(query)
    }

    
    // Fetch weekly stats for popular workouts and return as multiple Activity cards
    func fetchCurrentWeekWorkoutsStats(completion: @escaping(Result<[Activity], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                completion(.failure(error!))
                return
            }
            // Track time spent on each activity type (in minutes)
            var runningCount: Int = 0
            var cyclingCount: Int = 0
            var yogaCount: Int = 0
            var stairsCount: Int = 0
            var hikingCount: Int = 0
            var danceCount: Int = 0
            // Loop through each workout and categorize
            for workout in workouts {
                let duration = Int(workout.duration)/60
                if workout.workoutActivityType == .running {
                    runningCount += duration
                } else if workout.workoutActivityType == .cycling || workout.workoutActivityType == .handCycling {
                    cyclingCount += duration
                } else if workout.workoutActivityType == .yoga {
                    yogaCount += duration
                } else if workout.workoutActivityType == .stairClimbing || workout.workoutActivityType == .stairs {
                    stairsCount += duration
                } else if workout.workoutActivityType == .hiking {
                    hikingCount += duration
                } else if workout.workoutActivityType == .socialDance || workout.workoutActivityType == .cardioDance {
                    danceCount += duration
                }
            }
            // Convert all into Activity cards for display
            completion(.success(self.generateActivitiesFromDurations(running: runningCount, cycling: cyclingCount, yoga: yogaCount, stairs: stairsCount, hiking: hikingCount, dance: danceCount)))
            
        }
        healthStore.execute(query)
    }
    
    // Convert weekly workout durations into a list of Activity cards
    func generateActivitiesFromDurations(running: Int, cycling: Int, yoga: Int, stairs: Int, hiking: Int, dance: Int) -> [Activity] {
        return [
            Activity(title: "Running", subtitle: "This week", image: "figure.run", tintColor: .green, amount: "\(running) mins"),
            Activity(title: "Cycling", subtitle: "This week", image: "figure.outdoor.cycle", tintColor: .blue, amount: "\(cycling) mins"),
            Activity(title: "Yoga", subtitle: "This week", image: "figure.yoga", tintColor: .indigo, amount: "\(yoga) mins"),
            Activity(title: "Stairs Climbing", subtitle: "This week", image: "figure.stairs", tintColor: .purple, amount: "\(stairs) mins"),
            Activity(title: "Hiking", subtitle: "This week", image: "figure.hiking", tintColor: .cyan, amount: "\(hiking) mins"),
            Activity(title: "Dance", subtitle: "This week", image: "figure.dance", tintColor: .orange, amount: "\(dance) mins")
        ]
    }
    
    // MARK: Recent Workouts
    
    // Fetch all workouts for the current week
    func fetchWorkoutsForWeek(completion: @escaping(Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let startOfWeek = Date.startOfWeek
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let workouts = results as? [HKWorkout], error == nil else {
                completion(.failure(error!))
                return
            }
            
            // Print the fetched workouts
            print("Fetched Workouts Count: \(workouts.count)")
            for workout in workouts {
                print("Workout: \(workout.workoutActivityType.name) - \(workout.duration/60) mins on \(workout.startDate)")
            }

            // Convert each HKWorkout into a custom Workout model
            let workoutsArray = workouts.map({ Workout(
                title: $0.workoutActivityType.name,
                image: $0.workoutActivityType.image,
                tintColor: $0.workoutActivityType.color,
                duration: "\(Int($0.duration)/60) mins",
                date: $0.startDate,
                calories: ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()).formattedNumberString() ?? "-") + "kcal") })
                    
            completion(.success(workoutsArray))
        }
        healthStore.execute(query)
    }
    
    // Fetch workouts for a specific calendar month
    func fetchWorkoutsForMonth(month: Date, completion: @escaping(Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let (startDate, endDate) = month.fetchMonthStartAndEndDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let workouts = results as? [HKWorkout], error == nil else {
                completion(.failure(error!))
                return
            }
            
            // Print the fetched workouts
            print("Fetched Workouts Count: \(workouts.count)")
            for workout in workouts {
                print("Workout: \(workout.workoutActivityType.name) - \(workout.duration/60) mins on \(workout.startDate)")
            }

            // Convert each HKWorkout into a custom Workout model
            let workoutsArray = workouts.map({ Workout(
                title: $0.workoutActivityType.name,
                image: $0.workoutActivityType.image,
                tintColor: $0.workoutActivityType.color,
                duration: "\(Int($0.duration)/60) mins",
                date: $0.startDate,
                calories: ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()).formattedNumberString() ?? "-") + "kcal") })
            completion(.success(workoutsArray))
            
        }
        healthStore.execute(query)
    }
    
    // Enable background delivery so the app can be notified of updates automatically
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

    // Observe changes in health data and trigger app updates in the background
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
                    await ChartsDataViewModel().fetchAllHealthData()
                }
                
                completionHandler()
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: ChartsView Data
    
    // Fetch daily calories burned for the last 7 days
    func fetchOneWeekCaloriesData(completion: @escaping (Result<[DailyCaloriesModel], Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        var oneWeekCalories = [DailyCaloriesModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        // Fetch last 7 days including today
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                    
                    guard let calories = results?.sumQuantity()?.doubleValue(for: .kilocalorie()), error == nil else {
                        print("Error fetching data for day \(date): \(error?.localizedDescription ?? "Unknown error")")
                        oneWeekCalories.append(DailyCaloriesModel(date: date, calories: 0)) // Add 0 if no data
                        return
                    }
                    
                    // Append data and ensure the day is included even if calories are zero
                    oneWeekCalories.append(DailyCaloriesModel(date: date, calories: Int(calories)))
                }
                
                healthStore.execute(query)
            }
        }
        
        // Completion handler for all queries
        dispatchGroup.notify(queue: .main) {
            // Sort the data by date to ensure correct order
            let sortedData = oneWeekCalories.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

    // Fetch daily calories for the last 30 days
    func fetchOneMonthCaloriesData(completion: @escaping (Result<[DailyCaloriesModel], Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        var oneMonthCalories = [DailyCaloriesModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        // Fetch last 30 days
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                    
                    guard let calories = results?.sumQuantity()?.doubleValue(for: .kilocalorie()), error == nil else {
                        print("Error fetching calories for day \(date): \(error?.localizedDescription ?? "Unknown error")")
                        oneMonthCalories.append(DailyCaloriesModel(date: date, calories: 0)) // Add 0 if no data
                        return
                    }
                    
                    oneMonthCalories.append(DailyCaloriesModel(date: date, calories: Int(calories)))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneMonthCalories.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

    // Fetch total calories for each of the last 12 months
    func fetchOneYearCaloriesData(completion: @escaping (Result<[MonthlyCaloriesModel], Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        var rawData: [(date: Date, calories: Int)] = []
        let dispatchGroup = DispatchGroup()

        // fetch last 12 months including current month
        for i in (0..<12).reversed() {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)

                dispatchGroup.enter()
                let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() }

                    let kcal = results?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    rawData.append((date: startOfMonth, calories: Int(kcal)))
                }

                healthStore.execute(query)
            }
        }

        dispatchGroup.notify(queue: .main) {
            let sorted = rawData.sorted { $0.date < $1.date }
            let withPosition = sorted.enumerated().map { index, entry in
                MonthlyCaloriesModel(date: entry.date, calories: entry.calories, position: index)
            }
            completion(.success(withPosition))
        }
    }
    
    // Fetch daily active time for the past 7 days
    func fetchOneWeekActiveData(completion: @escaping (Result<[DailyActiveModel], Error>) -> Void) {
        let activeTime = HKQuantityType(.appleExerciseTime)
        let calendar = Calendar.current
        var oneWeekActive = [DailyActiveModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKStatisticsQuery(quantityType: activeTime, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                    
                    guard let activeMinutes = results?.sumQuantity()?.doubleValue(for: .minute()), error == nil else {
                        print("Error fetching active data for day \(date): \(error?.localizedDescription ?? "Unknown error")")
                        oneWeekActive.append(DailyActiveModel(date: date, count: 0)) // Add 0 if no data
                        return
                    }
                    
                    oneWeekActive.append(DailyActiveModel(date: date, count: Int(activeMinutes)))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Return sorted daily data
            let sortedData = oneWeekActive.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

    // Monthly Active Time Data
    func fetchOneMonthActiveData(completion: @escaping (Result<[DailyActiveModel], Error>) -> Void) {
        // Get last 30 days of exercise minutes
        let activeTime = HKQuantityType(.appleExerciseTime)
        let calendar = Calendar.current
        var oneMonthActive = [DailyActiveModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKStatisticsQuery(quantityType: activeTime, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                    
                    guard let activeMinutes = results?.sumQuantity()?.doubleValue(for: .minute()), error == nil else {
                        print("Error fetching active data for day \(date): \(error?.localizedDescription ?? "Unknown error")")
                        oneMonthActive.append(DailyActiveModel(date: date, count: 0)) // Add 0 if no data
                        return
                    }
                    
                    oneMonthActive.append(DailyActiveModel(date: date, count: Int(activeMinutes)))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneMonthActive.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

    // Yearly Active Time Data
    func fetchOneYearActiveData(completion: @escaping (Result<[MonthlyActiveModel], Error>) -> Void) {
        // Fetch monthly average active minutes for the past 12 months
        let activeTime = HKQuantityType(.appleExerciseTime)
        let calendar = Calendar.current
        var rawData: [(date: Date, count: Int)] = []

        let dispatchGroup = DispatchGroup()

        for i in (0..<12).reversed() {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)

                dispatchGroup.enter()

                let query = HKStatisticsQuery(quantityType: activeTime, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() }

                    let minutes = results?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                    rawData.append((date: startOfMonth, count: Int(minutes)))
                }

                healthStore.execute(query)
            }
        }

        dispatchGroup.notify(queue: .main) {
            let sorted = rawData.sorted { $0.date < $1.date }
            let withPosition = sorted.enumerated().map { index, entry in
                MonthlyActiveModel(date: entry.date, count: entry.count, position: index)
            }
            completion(.success(withPosition))
        }
    }

    
    // Fetch weekly stand data
    func fetchOneWeekStandData(completion: @escaping (Result<[DailyStandModel], Error>) -> Void) {
        // Get stand hours for each of the past 7 days
        let stand = HKCategoryType(.appleStandHour)
        let calendar = Calendar.current
        var oneWeekStand = [DailyStandModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let samples = results as? [HKCategorySample], error == nil else {
                        oneWeekStand.append(DailyStandModel(date: date, count: 0))
                        return
                    }
                    
                    let standHours = samples.filter { $0.value == 0 }.count
                    oneWeekStand.append(DailyStandModel(date: date, count: standHours))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneWeekStand.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }
    
    // Fetch Monthly Stand data
    func fetchOneMonthStandData(completion: @escaping (Result<[DailyStandModel], Error>) -> Void) {
        // Fetch last 30 days of stand data
        let stand = HKCategoryType(.appleStandHour)
        let calendar = Calendar.current
        var oneMonthStand = [DailyStandModel]()
            
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
            
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                    
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                    
                dispatchGroup.enter() // Enter the dispatch group
                    
                let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    defer { dispatchGroup.leave() }
                        
                    guard let samples = results as? [HKCategorySample], error == nil else {
                        oneMonthStand.append(DailyStandModel(date: date, count: 0))
                        return
                    }
                        
                    let standHours = samples.filter { $0.value == 0 }.count
                    oneMonthStand.append(DailyStandModel(date: date, count: standHours))
                }
                    
                healthStore.execute(query)
            }
        }
            
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneMonthStand.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }
    
    // Fetch One year stand data
    func fetchOneYearStandData(completion: @escaping (Result<[MonthlyStandModel], Error>) -> Void) {
        // Fetch monthly average stand hours for the past 12 months
        let stand = HKCategoryType(.appleStandHour)
        let calendar = Calendar.current
        var rawData: [(date: Date, count: Int)] = []
        
        let dispatchGroup = DispatchGroup()
        
        for i in (0..<12).reversed() {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
                
                dispatchGroup.enter()
                
                let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    defer { dispatchGroup.leave() }
                    
                    let samples = results as? [HKCategorySample]
                    let standHours = samples?.filter { $0.value == 0 }.count ?? 0
                    rawData.append((date: startOfMonth, count: standHours))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sorted = rawData.sorted { $0.date < $1.date }
            let withPosition = sorted.enumerated().map { index, entry in
                MonthlyStandModel(date: entry.date, count: entry.count, position: index)
            }
            completion(.success(withPosition))
        }
    }

}

      
// MARK: ChartsView Data for steps
extension HealthManager {
        
    struct WeekChartDataResult {
        let oneWeek: [DailyStepModel]
    }
            
    // Fetch step count for the past 7 days (for weekly chart)
    func fetchOneWeekStepData(completion: @escaping (Result<WeekChartDataResult, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        var oneWeekDays = [DailyStepModel]()
            
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
            
        // Fetch last 7 days including today
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
                    
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                    
                dispatchGroup.enter() // Enter the dispatch group
                    
                let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                        
                    guard let steps = results?.sumQuantity()?.doubleValue(for: .count()), error == nil else {
                        print("Error fetching data for day \(date): \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                        
                    // Append data and ensure the day is included even if steps are zero
                    let normalizedDate = calendar.startOfDay(for: date) // normalize the date
                    oneWeekDays.append(DailyStepModel(date: normalizedDate, count: Int(steps)))
                }
                    
                healthStore.execute(query)
            }
        }
            
        // Completion handler for all queries
        dispatchGroup.notify(queue: .main) {
            // Sort the data by date to ensure correct order
            let sortedData = oneWeekDays.sorted { $0.date < $1.date }
            completion(.success(WeekChartDataResult(oneWeek: sortedData)))
        }
    }
    
    // Monthly Steps Data
    struct MonthChartDataResult {
        let oneMonth: [DailyStepModel]
    }
    // Fetch step count for the past 30 days (for monthly chart)
    func fetchOneMonthStepData(completion: @escaping (Result<MonthChartDataResult, Error>) -> Void) {
        let stepsType = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        var oneMonthDays = [DailyStepModel]()
        let dispatchGroup = DispatchGroup()

        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -29, to: today)!

        for offset in 0..<30 {
            if let day = calendar.date(byAdding: .day, value: offset, to: startDate) {
                let startOfDay = calendar.startOfDay(for: day)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                    dispatchGroup.enter()

                let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate) { _, result, error in
                    defer { dispatchGroup.leave() }

                    let stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    oneMonthDays.append(DailyStepModel(date: day, count: Int(stepCount)))
                }

                healthStore.execute(query)
            }
        }

        dispatchGroup.notify(queue: .main) {
            let sorted = oneMonthDays.sorted { $0.date < $1.date }
            completion(.success(MonthChartDataResult(oneMonth: sorted)))
        }
    }

    // Yearly Steps Data
    struct YearChartDataResult {
        let oneYear: [MonthlyStepModel]
    }
    // Fetch monthly total step count for the last 12 months (for yearly chart)
    func fetchOneYearChartData(completion: @escaping (Result<YearChartDataResult, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        var oneYearRawData: [(date: Date, count: Int)] = []

        let dispatchGroup = DispatchGroup()

        for i in (0..<12).reversed() {
            if let monthDate = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = monthDate.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)

                dispatchGroup.enter()
                let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() }

                    var stepCount = 0
                    if let quantity = results?.sumQuantity() {
                        stepCount = Int(quantity.doubleValue(for: .count()))
                    } else {
                        print("Error fetching steps for \(monthDate): \(error?.localizedDescription ?? "No data")")
                    }

                    oneYearRawData.append((date: startOfMonth, count: stepCount))
                }

                healthStore.execute(query)
            }
        }

        dispatchGroup.notify(queue: .main) {
            let sortedWithIndex = oneYearRawData
                .sorted { $0.date < $1.date }
                .enumerated()
                .map { index, entry in
                    MonthlyStepModel(date: entry.date, count: entry.count, position: index)
                }
            
            completion(.success(YearChartDataResult(oneYear: sortedWithIndex)))
        }
    }
}

// MARK: TopPerformers View
extension HealthManager {
    // Get total steps for the current week (for leaderboard)
    func fetchCurrentWeekStepCount(completion: @escaping (Result<Double, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error!))
                return
            }
            
            let steps = quantity.doubleValue(for: .count())
            completion(.success(steps))
        }
        
        healthStore.execute(query)
    }
}
