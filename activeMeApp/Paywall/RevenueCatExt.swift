//
//  RevenueCatExt.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 28/03/2025.
//

import Foundation
import RevenueCat

extension SubscriptionPeriod {
    // Convert RevenueCat subscription unit into readable format
    var durationTitle: String {
        switch self.unit {
        case .day: return "Daily"
        case .week: return "Weekly"
        case .month: return "Monthly"
        case .year: return "Annual"
        @unknown default:
            return "Unknown"
        }
    }
}
