//
//  MonthlyCaloriesModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 26/02/2025.
//

import Foundation

// showes calories summary for a specific month
struct MonthlyCaloriesModel: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
    let position: Int     // Used to position bars in chart view
}
