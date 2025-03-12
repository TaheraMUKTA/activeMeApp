//
//  DateExt.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//


import Foundation

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
    
    func fetchPreviousMonday() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let daysToSubtract = (weekday + 5) % 7
        var dateComponents = DateComponents()
        dateComponents.day = -daysToSubtract
        return calendar.date(byAdding: dateComponents, to: self) ?? Date()
    }
    
    func mondayDateFormat() -> String {
        let monday = Date.startOfWeek
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: monday)
    }

}
