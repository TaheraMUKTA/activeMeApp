//
//  MonthlyCaloriesModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

struct MonthlyCaloriesModel: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
}
