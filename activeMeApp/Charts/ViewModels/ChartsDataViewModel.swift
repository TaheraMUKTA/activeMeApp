//
//  ChartsDataViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import Foundation
import SwiftUI

class ChartsDataViewModel: ObservableObject {
    
    var mockWeekChartData = [
        DailyStepModel(date: Date(), count: 80),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), count: 50),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), count: 30),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), count: 150),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), count: 350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), count: 150),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), count: 30),
        
    ]
    
    var mockYearChartData = [
        MonthlyStepModel(date: Date(), count: 0),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), count: 0),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(), count: 50),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(), count: 350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(), count: 150),
        
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date(), count: 270),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(), count: 460),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -7, to: Date()) ?? Date(), count: 450),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(), count: 390),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -9, to: Date()) ?? Date(), count: 270),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -10, to: Date()) ?? Date(), count: 240),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -11, to: Date()) ?? Date(), count: 120)
        
    ]
    
    
    var fullYearData: [MonthlyStepModel] {
        if oneYearChartData.isEmpty {
            return mockYearChartData
        } else {
            return oneYearChartData
        }
    }


   
    // Steps total and average
    @Published var oneWeekAverage = 0
    @Published var oneWeekTotal = 0
    @Published var oneMonthAverage = 0
    @Published var oneMonthTotal = 0
    @Published var oneYearAverage = 0
    @Published var oneYearTotal = 0
    
    // Calories total and average
    @Published var oneWeekCaloriesTotal = 0
    @Published var oneWeekCaloriesAverage = 0
    @Published var oneMonthCaloriesTotal = 0
    @Published var oneMonthCaloriesAverage = 0
    @Published var oneYearCaloriesTotal = 0
    @Published var oneYearCaloriesAverage = 0
    
    // Active total and average
    @Published var oneWeekActiveTotal = 0
    @Published var oneWeekActiveAverage = 0
    @Published var oneMonthActiveTotal = 0
    @Published var oneMonthActiveAverage = 0
    @Published var oneYearActiveTotal = 0
    @Published var oneYearActiveAverage = 0
    
    // Stand total and average
    @Published var oneWeekStandTotal = 0
    @Published var oneWeekStandAverage = 0
    @Published var oneMonthStandTotal = 0
    @Published var oneMonthStandAverage = 0
    @Published var oneYearStandTotal = 0
    @Published var oneYearStandAverage = 0
    
    @Published var mockOneMonthData = [DailyStepModel]()
    
    // Steps Data
    @Published var oneWeekChartData = [DailyStepModel]()
    @Published var oneMonthChartData = [DailyStepModel]()
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



    
    @Published var selectedMetric: ChartMetric = .steps
    
    let healthManager = HealthManager.shared
    
    
    init() {
        sortWeekData()
        let mockOneMonths = mockDataForDays(days: 30)
        DispatchQueue.main.async {
            self.mockOneMonthData = mockOneMonths
        }
        fetchOneWeekChartData()
        fetchOneMonthChartData()
        fetchOneYearChartData()
        fetchOneWeekCaloriesData()
        fetchOneMonthCaloriesData()
        fetchOneYearCaloriesData()
        fetchOneWeekActiveData()
        fetchOneMonthActiveData()
        fetchOneYearActiveData()
        fetchOneWeekStandData()
        fetchOneMonthStandData()
        fetchOneYearStandData()
            
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
            return 1.2...12.8 // Move this logic here so it can be dynamically changed if needed
        }
    
    private func sortWeekData() {
            mockWeekChartData.sort {
                let calendar = Calendar.current
                let weekday1 = calendar.component(.weekday, from: $0.date)
                let weekday2 = calendar.component(.weekday, from: $1.date)
                
                // Convert Sunday (1) to 8 to make Monday (2) come first
                let adjustedWeekday1 = weekday1 == 1 ? 8 : weekday1
                let adjustedWeekday2 = weekday2 == 1 ? 8 : weekday2
                
                return adjustedWeekday1 < adjustedWeekday2
            }
        }
    
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
    
    func fetchOneYearChartData() {
        healthManager.fetchOneYearChartData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneYearChartData = data.oneYear
                    self.oneYearTotal = self.oneYearChartData.reduce(0, { $0 + $1.count })
                    self.oneYearAverage = self.oneYearTotal / 12
                }
            case .failure(let error):
                print("Error fetching one year chart data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOneMonthChartData() {
        healthManager.fetchOneMonthChartData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneMonthChartData = data.oneMonth
                    self.oneMonthTotal = self.oneMonthChartData.reduce(0, { $0 + $1.count })
                    self.oneMonthAverage = self.oneMonthTotal / 30
                }
            case .failure(let error):
                print("Error fetching one month chart data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOneWeekChartData() {
        healthManager.fetchOneWeekChartData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneWeekChartData = data.oneWeek
                    self.oneWeekTotal = self.oneWeekChartData.reduce(0, { $0 + $1.count })
                    self.oneWeekAverage = self.oneWeekTotal / 7
                }
            case .failure(let error):
                print("Error fetching one week chart data: \(error.localizedDescription)")
            }
        }
    }


    func fetchOneWeekCaloriesData() {
        healthManager.fetchOneWeekCaloriesData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneWeekCaloriesData = data
                    self.oneWeekCaloriesTotal = self.oneWeekCaloriesData.reduce(0, { $0 + $1.calories })
                    self.oneWeekCaloriesAverage = self.oneWeekCaloriesTotal / 7
                }
            case .failure(let error):
                print("Error fetching one-week calories data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOneWeekActiveData() {
        healthManager.fetchOneWeekActiveData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneWeekActiveData = data
                    self.oneWeekActiveTotal = data.reduce(0, { $0 + $1.count })
                    self.oneWeekActiveAverage = self.oneWeekActiveTotal / 7
                }
            case .failure(let error):
                print("Error fetching one-week active data: \(error.localizedDescription)")
            }
        }
    }
    

    func fetchOneWeekStandData() {
        healthManager.fetchOneWeekStandData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneWeekStandData = data
                    self.oneWeekStandTotal = data.reduce(0, { $0 + $1.count })
                    self.oneWeekStandAverage = self.oneWeekStandTotal / 7
                }
            case .failure(let error):
                print("Error fetching one-week stand data: \(error.localizedDescription)")
            }
        }
    }

    
    func fetchOneMonthCaloriesData() {
        healthManager.fetchOneMonthCaloriesData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneMonthCaloriesData = data
                    self.oneMonthCaloriesTotal = data.reduce(0, { $0 + $1.calories })
                    self.oneMonthCaloriesAverage = self.oneMonthCaloriesTotal / 30
                }
            case .failure(let error):
                print("Error fetching one-month calories data: \(error.localizedDescription)")
            }
        }
    }
    
    func calculateOneMonthActiveTotals() {
        DispatchQueue.main.async {
            self.oneMonthActiveTotal = self.oneMonthActiveData.reduce(0, { $0 + $1.count })
            self.oneMonthActiveAverage = self.oneMonthActiveData.isEmpty ? 0 : self.oneMonthActiveTotal / self.oneMonthActiveData.count
        }
    }

    func calculateOneMonthStandTotals() {
        DispatchQueue.main.async {
            self.oneMonthStandTotal = self.oneMonthStandData.reduce(0, { $0 + $1.count })
            self.oneMonthStandAverage = self.oneMonthStandData.isEmpty ? 0 : self.oneMonthStandTotal / self.oneMonthStandData.count
        }
    }


    func fetchOneMonthActiveData() {
        healthManager.fetchOneMonthActiveData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneMonthActiveData = data
                    self.calculateOneMonthActiveTotals() // Calculate totals and average here
                }
            case .failure(let error):
                print("Error fetching one-month active data: \(error.localizedDescription)")
            }
        }
    }

    func fetchOneMonthStandData() {
        healthManager.fetchOneMonthStandData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneMonthStandData = data
                    self.calculateOneMonthStandTotals() // Calculate totals and average here
                }
            case .failure(let error):
                print("Error fetching one-month stand data: \(error.localizedDescription)")
            }
        }
    }


    func fetchOneYearCaloriesData() {
        healthManager.fetchOneYearCaloriesData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneYearCaloriesData = data
                    self.oneYearCaloriesTotal = data.reduce(0, { $0 + $1.calories })
                    self.oneYearCaloriesAverage = self.oneYearCaloriesTotal / 12
                }
            case .failure(let error):
                print("Error fetching one-year calories data: \(error.localizedDescription)")
            }
        }
    }

    func fetchOneYearActiveData() {
        healthManager.fetchOneYearActiveData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneYearActiveData = data
                    self.oneYearActiveTotal = data.reduce(0, { $0 + $1.count })
                    self.oneYearActiveAverage = self.oneYearActiveTotal / 12
                }
            case .failure(let error):
                print("Error fetching one-year active data: \(error.localizedDescription)")
            }
        }
    }

    func fetchOneYearStandData() {
        healthManager.fetchOneYearStandData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.oneYearStandData = data
                    self.oneYearStandTotal = data.reduce(0, { $0 + $1.count })
                    self.oneYearStandAverage = self.oneYearStandTotal / 12
                }
            case .failure(let error):
                print("Error fetching one-year stand data: \(error.localizedDescription)")
            }
        }
    }

    
}
