//
//  ChartsDataViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChartsDataViewModel: ObservableObject {
    // MARK: Weekly, Monthly and Yearly totals and averages
    // Steps
    @Published var oneWeekAverage = 0
    @Published var oneWeekTotal = 0
    @Published var oneMonthAverage = 0
    @Published var oneMonthTotal = 0
    @Published var oneYearAverage = 0
    @Published var oneYearTotal = 0
    
    // Calories
    @Published var oneWeekCaloriesTotal = 0
    @Published var oneWeekCaloriesAverage = 0
    @Published var oneMonthCaloriesTotal = 0
    @Published var oneMonthCaloriesAverage = 0
    @Published var oneYearCaloriesTotal = 0
    @Published var oneYearCaloriesAverage = 0
    
    // Active minutes
    @Published var oneWeekActiveTotal = 0
    @Published var oneWeekActiveAverage = 0
    @Published var oneMonthActiveTotal = 0
    @Published var oneMonthActiveAverage = 0
    @Published var oneYearActiveTotal = 0
    @Published var oneYearActiveAverage = 0
    
    // Stand hours
    @Published var oneWeekStandTotal = 0
    @Published var oneWeekStandAverage = 0
    @Published var oneMonthStandTotal = 0
    @Published var oneMonthStandAverage = 0
    @Published var oneYearStandTotal = 0
    @Published var oneYearStandAverage = 0
    
    // MARK: - Data Arrays for Chart Rendering
    @Published var mockOneMonthData = [DailyStepModel]()    // Used for testing
    
    // Steps Data
    @Published var oneWeekStepData = [DailyStepModel]()
    @Published var oneMonthStepData = [DailyStepModel]()
    @Published var oneYearChartData = [MonthlyStepModel]()
    
    // Calories Data
    @Published var oneWeekCaloriesData = [DailyCaloriesModel]()
    @Published var oneMonthCaloriesData = [DailyCaloriesModel]()
    @Published var oneYearCaloriesData = [MonthlyCaloriesModel]()
    
    // Active Data
    @Published var oneWeekActiveData = [DailyActiveModel]()
    @Published var oneMonthActiveData = [DailyActiveModel]()
    @Published var oneYearActiveData = [MonthlyActiveModel]()

    // Stand Data
    @Published var oneWeekStandData = [DailyStandModel]()
    @Published var oneMonthStandData = [DailyStandModel]()
    @Published var oneYearStandData = [MonthlyStandModel]()

    // Current selected metric for color switching
    @Published var selectedMetric: ChartMetric = .steps
    @Published var presentError = false    // Used to show permission error
    
    let healthManager = HealthManager.shared
   
    // MARK: - Initializer
    init() {
        Task {
            do {
                print("DEBUG: Requesting HealthKit access...")
                try await HealthManager.shared.requestHealthKitAccess()
                    print("DEBUG: HealthKit access granted.")

                    print("DEBUG: Fetching all health data...")
                await fetchAllHealthData()
                
            } catch {
                print("DEBUG: Failed to fetch HealthKit data: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.presentError = true
                }
            }
        }
    }
    
    
    // MARK: - Fetch All Health Data
    func fetchAllHealthData() async {
        do {
            print("DEBUG: Fetching health data...")
            
            // Run all fetch functions concurrently using async let
            async let oneWeekStep: () = try await fetchOneWeekStepData()
            async let oneMonthStep: () = try await fetchOneMonthStepData()
            async let oneYearStep: () = try await fetchOneYearStepData()
            async let oneWeekCalories: () = try await fetchOneWeekCaloriesData()
            async let oneMonthCalories: () = try await fetchOneMonthCaloriesData()
            async let oneYearCalories: () = try await fetchOneYearCaloriesData()
            async let oneWeekActive: () = try await fetchOneWeekActiveData()
            async let oneMonthActive: () = try await fetchOneMonthActiveData()
            async let oneYearActive: () = try await fetchOneYearActiveData()
            async let oneWeekStand: () = try await fetchOneWeekStandData()
            async let oneMonthStand: () = try await fetchOneMonthStandData()
            async let oneYearStand: () = try await fetchOneYearStandData()
            
            // Wait for all tasks to finish
            _ = (try await oneWeekStep, try await oneMonthStep, try await oneYearStep, try await oneWeekCalories, try await oneMonthCalories, try await oneYearCalories, try await oneWeekActive, try await oneMonthActive, try await oneYearActive, try await oneWeekStand, try await oneMonthStand, try await oneYearStand)
            
            // Save to Firestore after successful fetch
            await saveChartDataToFirestore()
            print("DEBUG: Finished fetching all health data.")
        } catch {
            print("DEBUG: Error fetching health data: \(error.localizedDescription)")
        }
    }

    
    // Determines the color of the bars based on the selected metric
    var selectedMetricColor: Color {
        switch selectedMetric {
        case .steps:
            return .purple.opacity(0.8)
        case .calories:
            return .red.opacity(0.8)
        case .active:
            return .green.opacity(0.8)
        case .stand:
            return .blue.opacity(0.8)
        }
    }
    
    var adjustedXScaleRange: ClosedRange<Double> {
        return 1.2...12.8
    }
    
    // Used for testing charts without real data
    func mockDataForDays(days: Int) -> [DailyStepModel] {
        var mockData = [DailyStepModel]()
        for day in 0..<days {
            let currentDate = Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date()
            let randomStepCount = Int.random(in: 5000...20000)
            let dailyStepData = DailyStepModel(date: currentDate, count: Int(randomStepCount))
            mockData.append(dailyStepData)
        }
        return mockData
    }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Short day format (Mon, Tue, Wed...)
        return formatter.string(from: date)
    }
    
    func dayOfMonth(from date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: date) // Extracts the day number (1-31)
    }
    
    
    // MARK: - Weekly Data Fetch Functions
    
    // Each fetch function retrieves data from HealthKit and calculates total and average
    // One Week Step data
    func fetchOneWeekStepData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneWeekStepData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        
                        self.oneWeekStepData = self.normalizeWeekData(data.oneWeek)
                        self.oneWeekTotal = self.oneWeekStepData.reduce(0, { $0 + $1.count })
                        self.oneWeekAverage = self.oneWeekTotal / 7
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Week Calories data
    func fetchOneWeekCaloriesData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneWeekCaloriesData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneWeekCaloriesData = data
                        self.oneWeekCaloriesTotal = self.oneWeekCaloriesData.reduce(0, { $0 + $1.calories })
                        self.oneWeekCaloriesAverage = self.oneWeekCaloriesTotal / 7
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Week Active data
    func fetchOneWeekActiveData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneWeekActiveData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneWeekActiveData = data
                        self.oneWeekActiveTotal = data.reduce(0, { $0 + $1.count })
                        self.oneWeekActiveAverage = self.oneWeekActiveTotal / 7
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Week Stand data
    func fetchOneWeekStandData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneWeekStandData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneWeekStandData = data
                        self.oneWeekStandTotal = data.reduce(0, { $0 + $1.count })
                        self.oneWeekStandAverage = self.oneWeekStandTotal / 7
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    

    // MARK: - Monthly Data Fetch Functions
    // One Month Step data
    func fetchOneMonthStepData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneMonthStepData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneMonthStepData = data.oneMonth
                        self.oneMonthTotal = self.oneMonthStepData.reduce(0, { $0 + $1.count })
                        self.oneMonthAverage = self.oneMonthTotal / 30
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    
    // One Month Calories data
    func fetchOneMonthCaloriesData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneMonthCaloriesData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneMonthCaloriesData = data
                        self.oneMonthCaloriesTotal = data.reduce(0, { $0 + $1.calories })
                        self.oneMonthCaloriesAverage = self.oneMonthCaloriesTotal / 30
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // Used to calculate totals for active time
    func calculateOneMonthActiveTotals() {
        DispatchQueue.main.async {
            self.oneMonthActiveTotal = self.oneMonthActiveData.reduce(0, { $0 + $1.count })
            self.oneMonthActiveAverage = self.oneMonthActiveData.isEmpty ? 0 : self.oneMonthActiveTotal / self.oneMonthActiveData.count
        }
    }

    // Used to calculate totals for stand time
    func calculateOneMonthStandTotals() {
        DispatchQueue.main.async {
            self.oneMonthStandTotal = self.oneMonthStandData.reduce(0, { $0 + $1.count })
            self.oneMonthStandAverage = self.oneMonthStandData.isEmpty ? 0 : self.oneMonthStandTotal / self.oneMonthStandData.count
        }
    }

    // One Month Active time data
    func fetchOneMonthActiveData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneMonthActiveData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneMonthActiveData = data
                        self.calculateOneMonthActiveTotals() // Calculate totals and average here
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }

    
    // One Month Syand data
    func  fetchOneMonthStandData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneMonthStandData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneMonthStandData = data
                        self.calculateOneMonthStandTotals() // Calculate totals and average here
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }


    // MARK: - Yearly Data Fetch Functions
    // One Year Step data
    func  fetchOneYearStepData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneYearChartData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneYearChartData = data.oneYear
                        self.oneYearTotal = self.oneYearChartData.reduce(0, { $0 + $1.count })
                        self.oneYearAverage = self.oneYearTotal / 12
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Year Calories data
    func  fetchOneYearCaloriesData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneYearCaloriesData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneYearCaloriesData = data
                        self.oneYearCaloriesTotal = data.reduce(0, { $0 + $1.calories })
                        self.oneYearCaloriesAverage = self.oneYearCaloriesTotal / 12
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Year Active time data
    func  fetchOneYearActiveData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneYearActiveData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneYearActiveData = data
                        self.oneYearActiveTotal = data.reduce(0, { $0 + $1.count })
                        self.oneYearActiveAverage = self.oneYearActiveTotal / 12
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // One Year Stand time data
    func  fetchOneYearStandData() async throws {
        try await withCheckedThrowingContinuation ({ continuation in
            healthManager.fetchOneYearStandData { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.oneYearStandData = data
                        self.oneYearStandTotal = data.reduce(0, { $0 + $1.count })
                        self.oneYearStandAverage = self.oneYearStandTotal / 12
                        continuation.resume()
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }) as Void
    }
    
    // MARK: - Normalize Week Data (e.g., fill missing days with 0)
    func normalizeWeekData(_ data: [DailyStepModel]) -> [DailyStepModel] {
        var normalized: [DailyStepModel] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // ensure consistency

        for offset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let dayStart = calendar.startOfDay(for: date) // normalize to midnight
                if let match = data.first(where: { calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: dayStart) }) {
                    normalized.append(DailyStepModel(date: dayStart, count: match.count))
                } else {
                    normalized.append(DailyStepModel(date: dayStart, count: 0))
                }
            }
        }
        return normalized
    }

    // MARK: - Save Chart Data to Firestore
    
    func saveChartDataToFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let chartData: [String: Any] = [
            "lastUpdated": Timestamp(date: Date()),

            // Steps
            "oneWeekTotalSteps": oneWeekTotal,
            "oneWeekAvgSteps": oneWeekAverage,
            "oneMonthTotalSteps": oneMonthTotal,
            "oneMonthAvgSteps": oneMonthAverage,
            "oneYearTotalSteps": oneYearTotal,
            "oneYearAvgSteps": oneYearAverage,

            // Calories
            "oneWeekTotalCalories": oneWeekCaloriesTotal,
            "oneWeekAvgCalories": oneWeekCaloriesAverage,
            "oneMonthTotalCalories": oneMonthCaloriesTotal,
            "oneMonthAvgCalories": oneMonthCaloriesAverage,
            "oneYearTotalCalories": oneYearCaloriesTotal,
            "oneYearAvgCalories": oneYearCaloriesAverage,

            // Active Minutes
            "oneWeekTotalActive": oneWeekActiveTotal,
            "oneWeekAvgActive": oneWeekActiveAverage,
            "oneMonthTotalActive": oneMonthActiveTotal,
            "oneMonthAvgActive": oneMonthActiveAverage,
            "oneYearTotalActive": oneYearActiveTotal,
            "oneYearAvgActive": oneYearActiveAverage,

            // Stand Hours
            "oneWeekTotalStand": oneWeekStandTotal,
            "oneWeekAvgStand": oneWeekStandAverage,
            "oneMonthTotalStand": oneMonthStandTotal,
            "oneMonthAvgStand": oneMonthStandAverage,
            "oneYearTotalStand": oneYearStandTotal,
            "oneYearAvgStand": oneYearStandAverage
        ]

        do {
            try await Firestore.firestore()
                .collection("chartData")
                .document(userId)
                .setData(chartData, merge: true)
            print("Chart data successfully saved to Firestore.")
        } catch {
            print("Error saving chart data: \(error.localizedDescription)")
        }
    }
}
