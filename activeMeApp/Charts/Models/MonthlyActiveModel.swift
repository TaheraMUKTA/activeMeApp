//
//  MonthlyActiveModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 27/02/2025.
//

import Foundation

// shows active minutes summary for a specific month
struct MonthlyActiveModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let position: Int     // Used to position bars in chart view
}

