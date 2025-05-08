//
//  ProfileViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 14/03/2025.
//

import Foundation
import SwiftUI
import MessageUI
import Firebase
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    
    @Published var user: User?     // Holds the current logged-in user data
    @Published var bmi: Double? = nil     // Stores calculated BMI
    
    // Function to set the user data & calculate BMI
    func setUser(_ user: User) {
        self.user = user
        recalculateBMI(height: user.height, weight: user.weight)
    }
    
    // Function to recalculate BMI when height or weight changes
    func recalculateBMI(height: String, weight: String) {
        guard let heightValue = Double(height), let weightValue = Double(weight), heightValue > 0 else {
            self.bmi = nil
            return
        }
        let heightInMeters = heightValue / 100.0
        self.bmi = weightValue / (heightInMeters * heightInMeters)
        objectWillChange.send() // Force UI refresh
    }

    // Format BMI for display (1 decimal place)
    var bmiString: String {
        if let bmi = bmi {
            return String(format: "%.1f", bmi)
        }
        return "N/A"
    }
    
    // BMI Category Classification
    var bmiCategory: String {
        guard let bmiValue = bmi else { return "N/A" }
        switch bmiValue {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
}

