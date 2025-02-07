//
//  DailyStepModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import Foundation

struct DailyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
