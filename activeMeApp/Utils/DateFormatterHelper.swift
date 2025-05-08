//
//  DateFormatterHelper.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import Foundation

struct DateFormatterHelper {
    static let shared = DateFormatterHelper()  // Singleton instance
    
    private let formatter: DateFormatter
    
    private init() {
        formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"  // Customize format here
    }
    
    // Converts a `Date` object to a formatted string.
    func formatDate(_ date: Date) -> String {
        return formatter.string(from: date)
    }
    
    // Parses a date string into a `Date` object, if valid.
    func parseDate(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
