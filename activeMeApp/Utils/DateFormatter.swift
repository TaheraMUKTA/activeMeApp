//
//  DateFormatter.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import Foundation

class DateFormatterUtils {
    // Formats a UNIX timestamp into a specified string format (e.g. "dd MMM yyyy")
    static func formattedDate(from timestamp: Int, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // Formats a timestamp to show hour + AM/PM (e.g., "02 PM Fri")
    static func formattedDateWithDay(from timestamp: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh a E" // Format: 12-hour time with AM/PM and day
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    // Formats a timestamp to full weekday and day number (e.g., "Friday 26")
    static func formattedDateWithWeekdayAndDay(from timestamp: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    // Formats a timestamp with date and time (e.g., "26 Apr 2025 at 4 PM")
    static func formattedDateTime(from timestamp: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy 'at' h a"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    // Formats the current local time based on a timezone offset (in seconds)
    static func formattedTimeForTimeZone(offset: Int, format: String) -> String {
        let localTime = Date().addingTimeInterval(TimeInterval(offset))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: localTime)
    }
    
    // Formats a specific timestamp with a timezone offset into a readable time string (e.g., "6:30 AM")
    static func formattedTime(for timestamp: Int, offset: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp + offset))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Example: "6:30 AM"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }

    // Formats a specific timestamp with a timezone offset into a readable time string (e.g., "6:30 AM")
    static func formattedLocalTime(from timestamp: TimeInterval, timezoneOffset: Int) -> String {
        let localTime = Date(timeIntervalSince1970: timestamp + TimeInterval(timezoneOffset))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh a E" // Example: "02 PM Fri"
        return dateFormatter.string(from: localTime)
    }
    
}

extension DateFormatterUtils {
    // Formats a `Date` to "dd MMM yyyy" (e.g., "25 Apr 2025")
    static func formattedDateWithFullMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}
