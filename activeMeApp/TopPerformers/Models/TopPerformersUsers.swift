//
//  TopPerformersUsers.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import Foundation

struct TopPerformersUsers: Codable, Identifiable {
    let id: String  // Use `id` as `userId` from Authentication
    var profilename: String  // Change this from nickname
    let count: Int
    
    init(id: String, profilename: String = "", count: Int) {
        self.id = id
        self.profilename = profilename
        self.count = count
    }
}
