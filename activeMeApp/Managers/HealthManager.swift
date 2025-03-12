//
//  HealthManager.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 04/02/2025.
//

import Foundation
import HealthKit

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
    
    
    func fetchTodayActiveTimeAsActivity(completion: @escaping (Result<Activity, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
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

    
    func fetchTodayStandTimeAsActivity(completion: @escaping (Result<Activity, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
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
            var yogaCount: Int = 0
            var stairsCount: Int = 0
            var hikingCount: Int = 0
            var danceCount: Int = 0
             
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
            
            completion(.success(self.generateActivitiesFromDurations(running: runningCount, cycling: cyclingCount, yoga: yogaCount, stairs: stairsCount, hiking: hikingCount, dance: danceCount)))
            
        }
        healthStore.execute(query)
    }
    
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
            print("Fetched Workouts Count: \(workouts.count)")
            for workout in workouts {
                print("Workout: \(workout.workoutActivityType.name) - \(workout.duration/60) mins on \(workout.startDate)")
            }

            
            let workoutsArray = workouts.map({ Workout(
                id: UUID().hashValue,
                tital: $0.workoutActivityType.name,
                image: $0.workoutActivityType.image,
                tintColor: $0.workoutActivityType.color,
                duration: "\(Int($0.duration)/60) mins",
                date: $0.startDate.formatWorkoutDate(),
                calories: ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()).formattedNumberString() ?? "-") + "kcal") })
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

    
    func fetchOneYearCaloriesData(completion: @escaping (Result<[MonthlyCaloriesModel], Error>) -> Void) {
            let calories = HKQuantityType(.activeEnergyBurned)
            let calendar = Calendar.current
            var oneYearCalories = [MonthlyCaloriesModel]()
            
            let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
            
            // Fetch last 12 months
            for i in 0..<12 {
                if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                    let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                    let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
                    
                    dispatchGroup.enter() // Enter the dispatch group
                    
                    let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
                        defer { dispatchGroup.leave() } // Leave when query finishes
                        
                        guard let calories = results?.sumQuantity()?.doubleValue(for: .kilocalorie()), error == nil else {
                            print("Error fetching calories for month \(month): \(error?.localizedDescription ?? "Unknown error")")
                            oneYearCalories.append(MonthlyCaloriesModel(date: month, calories: 0))
                            return
                        }
                        
                        oneYearCalories.append(MonthlyCaloriesModel(date: month, calories: Int(calories)))
                    }
                    
                    healthStore.execute(query)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                let sortedData = oneYearCalories.sorted { $0.date < $1.date }
                completion(.success(sortedData))
            }
        }
    
    
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
            let sortedData = oneWeekActive.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

    
    func fetchOneMonthActiveData(completion: @escaping (Result<[DailyActiveModel], Error>) -> Void) {
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

    
    func fetchOneYearActiveData(completion: @escaping (Result<[MonthlyActiveModel], Error>) -> Void) {
        let activeTime = HKQuantityType(.appleExerciseTime)
        let calendar = Calendar.current
        var oneYearActive = [MonthlyActiveModel]()
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
                
                dispatchGroup.enter()
                
                let query = HKStatisticsQuery(quantityType: activeTime, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let activeMinutes = results?.sumQuantity()?.doubleValue(for: .minute()), error == nil else {
                        print("Error fetching active time for month \(month): \(error?.localizedDescription ?? "Unknown error")")
                        oneYearActive.append(MonthlyActiveModel(date: month, count: 0))
                        return
                    }
                    
                    oneYearActive.append(MonthlyActiveModel(date: month, count: Int(activeMinutes)))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneYearActive.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }
    
    
    func fetchOneWeekStandData(completion: @escaping (Result<[DailyStandModel], Error>) -> Void) {
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
    
    func fetchOneMonthStandData(completion: @escaping (Result<[DailyStandModel], Error>) -> Void) {
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
    
    func fetchOneYearStandData(completion: @escaping (Result<[MonthlyStandModel], Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let calendar = Calendar.current
        var oneYearStand = [MonthlyStandModel]()
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
                
                dispatchGroup.enter()
                
                let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let samples = results as? [HKCategorySample], error == nil else {
                        print("Error fetching stand time for month \(month): \(error?.localizedDescription ?? "Unknown error")")
                        oneYearStand.append(MonthlyStandModel(date: month, count: 0))
                        return
                    }
                    
                    let standHours = samples.filter { $0.value == 0 }.count
                    oneYearStand.append(MonthlyStandModel(date: month, count: standHours))
                }
                
                healthStore.execute(query)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedData = oneYearStand.sorted { $0.date < $1.date }
            completion(.success(sortedData))
        }
    }

}

      
    // MARK: ChartsView Data
    extension HealthManager {
        
        struct WeekChartDataResult {
                let oneWeek: [DailyStepModel]
            }
            
            func fetchOneWeekChartData(completion: @escaping (Result<WeekChartDataResult, Error>) -> Void) {
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
                        oneWeekDays.append(DailyStepModel(date: date, count: Int(steps)))
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
    
    
    struct MonthChartDataResult {
            let oneMonth: [DailyStepModel]
        }
        
        func fetchOneMonthChartData(completion: @escaping (Result<MonthChartDataResult, Error>) -> Void) {
            let steps = HKQuantityType(.stepCount)
            let calendar = Calendar.current
            var oneMonthDays = [DailyStepModel]()
            
            let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
            
            // Fetch last 30 days
            for i in 0..<30 {
                if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                    let startOfDay = calendar.startOfDay(for: day)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
                    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
                    
                    dispatchGroup.enter() // Enter the dispatch group
                    
                    let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
                        defer { dispatchGroup.leave() } // Leave when query finishes
                        
                        guard let steps = results?.sumQuantity()?.doubleValue(for: .count()), error == nil else {
                            print("Error fetching data for day \(day): \(error?.localizedDescription ?? "Unknown error")")
                            oneMonthDays.append(DailyStepModel(date: day, count: 0)) // Add 0 if no data
                            return
                        }
                        
                        // Append data, even if steps are zero
                        oneMonthDays.append(DailyStepModel(date: day, count: Int(steps)))
                    }
                    
                    healthStore.execute(query)
                }
            }
            
            // Completion handler for all queries
            dispatchGroup.notify(queue: .main) {
                // Sort the data by date to ensure correct order
                let sortedData = oneMonthDays.sorted { $0.date < $1.date }
                completion(.success(MonthChartDataResult(oneMonth: sortedData)))
            }
        }
    
    
    
    struct YearChartDataResult {
        let oneYear: [MonthlyStepModel]
    }
    
    func fetchOneYearChartData(completion: @escaping (Result<YearChartDataResult, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        var oneYearMonths = [MonthlyStepModel]()
        
        let dispatchGroup = DispatchGroup() // Manage multiple asynchronous queries
        
        // Fetch last 12 months
        for i in 0...11 {
            if let month = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
                let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
                
                dispatchGroup.enter() // Enter the dispatch group
                
                let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
                    defer { dispatchGroup.leave() } // Leave when query finishes
                    
                    guard let steps = results?.sumQuantity()?.doubleValue(for: .count()), error == nil else {
                        print("Error fetching data for month \(month): \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Append data and ensure the month is included even if steps are zero
                    oneYearMonths.append(MonthlyStepModel(date: month, count: Int(steps)))
                }
                
                healthStore.execute(query)
            }
        }
        
        // Completion handler for all queries
        dispatchGroup.notify(queue: .main) {
            // Sort the data by date to ensure correct order
            let sortedData = oneYearMonths.sorted { $0.date < $1.date }
            completion(.success(YearChartDataResult(oneYear: sortedData)))
        }
    }
}

 // MARK: TopPerformers View
extension HealthManager {
    
    func fetchCurrentWeekStepCount(completion: @escaping (Result<Double, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
               
            let steps = quantity.doubleValue(for: .count())
            completion(.success(steps))
        }
        
        healthStore.execute(query)
    }
    
}
