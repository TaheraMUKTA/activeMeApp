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
    
    func formatDate(_ date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func parseDate(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
