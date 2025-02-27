//
//  MonthlyActiveModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

struct MonthlyActiveModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

