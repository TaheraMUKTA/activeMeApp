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
        DailyStepModel(date: Date(), count: 16780),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), count: 10350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), count: 12350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), count: 15350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), count: 13350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), count: 11350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), count: 8350),
        
    ]
    
    var mockYearChartData = [
        MonthlyStepModel(date: Date(), count: 50780),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), count: 32350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(), count: 24350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(), count: 43350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(), count: 35350),
        
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date(), count: 27350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(), count: 46350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -7, to: Date()) ?? Date(), count: 48350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(), count: 39350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -9, to: Date()) ?? Date(), count: 27350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -10, to: Date()) ?? Date(), count: 24350),
        MonthlyStepModel(date: Calendar.current.date(byAdding: .month, value: -11, to: Date()) ?? Date(), count: 12350)
        
    ]
    
    /// Ensures that all 12 months are present in the dataset
    var fullYearData: [MonthlyStepModel] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        
        // Generate dates for each month (from Jan to Dec)
        let allMonths = (1...12).compactMap { month -> MonthlyStepModel? in
            guard let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return nil }
            
            // Check if data already exists for this month
            if let existingData = mockYearChartData.first(where: { calendar.component(.month, from: $0.date) == month }) {
                return existingData
            } else {
                return MonthlyStepModel(date: monthDate, count: 0) // Fill missing months with zero steps
            }
        }

        return allMonths.sorted { $0.date < $1.date } // Ensure correct order (Jan → Dec)
    }


   
    
    @Published var oneWeekAverage = 1253
    @Published var oneWeekTotal = 8960
    @Published var mockOneMonthData = [DailyStepModel]()
    @Published var oneMonthAverage = 7956
    @Published var oneMonthTotal = 12668
    @Published var oneYearAverage = 13578
    @Published var oneYearTotal = 1345678
    @Published var selectedMetric: ChartMetric = .steps
    
    
    
    init() {
        sortWeekData()
        let mockOneMonths = mockDataForDays(days: 30)
        DispatchQueue.main.async {
            self.mockOneMonthData = mockOneMonths
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
            let randomStepCount = Int.random(in: 5000...25000)
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


    
}
