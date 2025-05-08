//
//  ProfileButtonView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 09/02/2025.
//

import SwiftUI

struct ProfileButtonView: View {
    @State var image: String     // SF Symbol name
    @State var title: String     // Button title text
    var action: (() -> Void)
    
    var body: some View {
        // Dynamically adapts text color based on light/dark mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        
        VStack {
            Button {
                action()
            } label: {
                HStack {
                    Image(systemName: image)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    Text(title)
                        .foregroundColor(adaptiveColor)
                    
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background( RoundedRectangle(cornerRadius: 10)
            .fill(.gray.opacity(0.1)))
        .padding(.horizontal, 5)
        
    }
}

struct ProfileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileButtonView(image: "square.and.pencil", title: "Edit User Name") {}
    }
}
