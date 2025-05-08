//
//  DailyActiveModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

// Stores active minutes data for a specific date
struct DailyActiveModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

