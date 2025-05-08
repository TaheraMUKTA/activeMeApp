//
//  DateUtills.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 26/02/2025.
//

import Foundation

// Returns the last 12 months including the current month at the end
func getLast12Months() -> [String] {
    let calendar = Calendar.current
    var months: [String] = []
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"

    for i in (0..<12).reversed() {
        if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
            months.append(formatter.string(from: date))
        }
    }

    return months
}

// Returns the last 30 day labels (e.g. "16", "17", ...)
func getLast30DayLabels() -> [String] {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let startDate = calendar.date(byAdding: .day, value: -29, to: today)!

    var labels: [String] = []
    for i in 0..<30 {
        if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
            labels.append(formatter.string(from: date))
        }
    }
    return labels
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

extension Date {
    // Returns the first day of the current month
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }

    // Returns the last day of the current month
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    // Returns an array of `Date` objects for each day from the start of the current month to today
    static func currentMonthDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = today.startOfMonth
        let endOfToday = calendar.startOfDay(for: today)

        var dates: [Date] = []
        var current = startOfMonth

        while current <= endOfToday {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return dates
    }
    
}

