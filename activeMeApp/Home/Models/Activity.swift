//
//  Activity.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

// shows a single activity summary (e.g. Steps, Calories)
struct Activity: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String
    let tintColor: Color
    let amount: String
    
    // Hashable Conformance - Uses title as a unique key
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    // Activities are considered equal if they have the same title
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.title == rhs.title
    }
    
}
