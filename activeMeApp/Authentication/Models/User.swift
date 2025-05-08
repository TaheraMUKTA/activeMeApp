//
//  User.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import Foundation

// User model that conforms to Identifiable and Codable
struct User: Identifiable, Codable {
    let id: String
    let email: String
    var profileName: String
    let dob: String
    let height: String
    let weight: String
    let gender: String
    let password: String
    var profileAvatar: String?
   
}

// Mock user for testing purposes
extension User {
    static var MOCK_USER = User(
        id: NSUUID().uuidString,
        email: "test@test.com",
        profileName: "Test User",
        dob: "06/05/2003",
        height: "170",
        weight: "70",
        gender: "male",
        password: "123456"
    )
}
