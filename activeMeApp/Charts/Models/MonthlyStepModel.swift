//
//  MonthlyStepModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import Foundation

// showes step count summary for a specific month
struct MonthlyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let position: Int     // Used to position bars in chart view
}
