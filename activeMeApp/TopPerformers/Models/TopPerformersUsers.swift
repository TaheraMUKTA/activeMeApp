//
//  TopPerformersUsers.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/03/2025.
//

import Foundation

struct TopPerformersUsers: Codable, Identifiable {
    let id: String  // Unique identifier (user ID from Firebase Authentication)
    var profilename: String  // Display name of the user
    let count: Int       // Step count
    
    init(id: String, profilename: String = "", count: Int) {
        self.id = id
        self.profilename = profilename
        self.count = count
    }
}
