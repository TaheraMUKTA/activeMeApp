//
//  DailyCaloriesModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

struct DailyCaloriesModel: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
}
