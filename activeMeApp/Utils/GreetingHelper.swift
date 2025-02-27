//
//  GreetingHelper.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 25/02/2025.
//

import Foundation

struct GreetingHelper {
    static var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        case 18..<23:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
}

