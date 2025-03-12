//
//  UserDetailsView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import SwiftUI

struct UserDetailsView: View {
    let user: User
    
    var bmi: Double? {
           if let height = Double(user.height), let weight = Double(user.weight), height > 0 {
               let heightInMeters = height / 100.0
               return weight / (heightInMeters * heightInMeters)
           }
           return nil
       }

       // ✅ BMI Category Classification
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

    var body: some View {
        VStack(spacing: 15) {
            Text("User Details")
                .font(.title)
                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                .fontWeight(.bold)
                .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 10) {
                    DetailsRowView(title: "Name", value: user.profileName)
                    DetailsRowView(title: "Email", value: user.email)
                    DetailsRowView(title: "Date of Birth", value: user.dob)
                    DetailsRowView(title: "Height", value: "\(user.height) cm")
                    DetailsRowView(title: "Weight", value: "\(user.weight) kg")
                    DetailsRowView(title: "Gender", value: user.gender)
                    if let bmiValue = bmi {
                        DetailsRowView(title: "BMI", value: String(format: "%.1f", bmiValue))
                            .foregroundColor(.blue)
                        DetailsRowView(title: "Category", value: bmiCategory)
                            .foregroundColor(bmiCategory == "Normal" ? .green : .red)
                    } else {
                        DetailsRowView(title: "BMI", value: "N/A")
                        DetailsRowView(title: "Category", value: "N/A")
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}


#Preview {
    UserDetailsView(user: User(id: "1", email: "test@example.com", profileName: "John Doe", dob: "12 Jan 2000", height: "175", weight: "70", gender: "Male", password: "" ))
}

