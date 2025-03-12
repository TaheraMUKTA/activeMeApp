//
//  DateUtils.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 26/02/2025.
//

import Foundation

// Returns the last 12 months including the current month at the end
func getLast12Months() -> [String] {
    let calendar = Calendar.current
    var months: [String] = []
    
    for i in 0..<12 {
        if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
            months.append(monthName)
        }
    }
    
    return months.reversed() // Reverse to have the current month at the end
}

// Returns the last 30 days including today at the end
func getLast30Days() -> [String] {
    let calendar = Calendar.current
    var days: [String] = []
    
    for i in 0..<30 {
        if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
            let day = calendar.component(.day, from: date)
            days.append("\(day)")
        }
    }
    
    return days.reversed() // Reverse to have today's date at the end
}

// Returns the last 7 days including today at the end
func getLast7Days() -> [String] {
    let calendar = Calendar.current
    var days: [String] = []
    
    for i in 0..<7 {
        if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
            let day = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            days.append(day.prefix(3).uppercased()) // e.g., "MON", "TUE", "WED"
        }
    }
    
    return days.reversed() // Reverse to have today's date at the end
}

