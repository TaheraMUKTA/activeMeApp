//
//  User.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    var profileName: String
    let dob: Date
    let height: String
    let weight: String
    let gender: String
    let password: String
        
       
    var formattedDOB: String {
        DateFormatterHelper.shared.formatDate(dob)
    }
   
}

extension User {
    static var MOCK_USER = User(
        id: NSUUID().uuidString,
        email: "test@test.com",
        profileName: "Test User",
        dob: Date(),
        height: "170",
        weight: "70",
        gender: "male",
        password: "123456"
    )
}
