//
//  InputView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import SwiftUI

struct InputView: View {
    // Binds user input
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureTextEntry = false     // Toggle secure entry (for passwords)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Field label
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(.darkGray))
            
            // Display secure or normal text field
            if isSecureTextEntry {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                    
            }
            
            Divider()
        }
        .padding(.bottom, 10)
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
