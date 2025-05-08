//
//  ProfileEditButtonView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 10/02/2025.
//

import SwiftUI

struct ProfileEditButtonView: View {
    @State var title: String        // Button title
    @State var backgroundColor: Color     // Button background color
    var action: (() -> Void)
    var body: some View {
        Button {
            action()
            
        } label: {
        
            Text(title)
                .font(.headline)
                .padding()
                .frame(width: 130)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
                .cornerRadius(15)
        }
    }
}

struct ProfileEditButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditButtonView(title: "", backgroundColor: .green) {}
        
    }
}
