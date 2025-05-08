//
//  DailyStandModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

// Stores standing hours data for a specific date
struct DailyStandModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
