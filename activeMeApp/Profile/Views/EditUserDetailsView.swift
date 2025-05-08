//
//  EditUserDetailsView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 18/03/2025.
//

import SwiftUI

struct EditUserDetailsView: View {
    let field: String      // Determines which field is being edited ("Name", "Height", "Weight")
    let user: User
    
    @Binding var updatedName: String
    @Binding var updatedHeight: String
    @Binding var updatedWeight: String
    
    var onSave: () -> Void    // Callback triggered when "Save" or "Cancel" is pressed
    
    var body: some View {
        // Adaptive text color based on light/dark mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        
        VStack(spacing: 20) {
            // Conditional field input based on selected field
            if field == "Name" {
                TextField("Enter new name", text: $updatedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(adaptiveColor)
            } else if field == "Height" {
                TextField("Enter new height (cm)", text: $updatedHeight)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(adaptiveColor)
            } else if field == "Weight" {
                TextField("Enter new weight (kg)", text: $updatedWeight)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(adaptiveColor)
            }
            
            // Save button
            Button("Save") {
                onSave()     // Saves the new data and dismisses
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Cancel button
            Button("Cancel") {
                onSave()    // Reuse same action to close view without saving
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

