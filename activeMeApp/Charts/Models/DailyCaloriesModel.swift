//
//  DailyCaloriesModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 26/02/2025.
//

import Foundation

// Stores calories burned for a specific date
struct DailyCaloriesModel: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
}
