//
//  Workout.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

// shows a saved workout session
struct Workout: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let tintColor: Color
    let duration: String
    let date: Date
    let calories: String
}

