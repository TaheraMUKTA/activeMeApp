//
//  ButtonView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import SwiftUI

// A reusable button component with title and system image
struct ButtonView: View {
    var title: String
    var image: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                        
                Image(systemName: image)  // SF Symbol icon
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 15/255, green: 174/255, blue: 1/255))
            .cornerRadius(10)
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
}

#Preview {
    ButtonView(title: "SIGN IN", image: "arrow.right") {}
}
