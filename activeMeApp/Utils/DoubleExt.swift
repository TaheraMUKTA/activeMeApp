//
//  DoubleExt.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import Foundation

extension Double {
    // Formats a `Double` value into a string with no decimal places and thousands separator.
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal     // Uses grouping separator (e.g., "1,000")
        formatter.maximumFractionDigits = 0      // Rounds to the nearest whole number
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
